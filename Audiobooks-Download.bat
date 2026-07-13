@echo off
chcp 65001 >nul
setlocal EnableExtensions EnableDelayedExpansion
title WCN Audiobooks Downloader

rem ===========================================================
rem   Audiobooks-Download.bat
rem   Archive.org audiobook downloader
rem   - Resume-safe (curl -C -)
rem   - Live progress meter per file
rem   - Fetches the current audiobook file list from archive.org
rem   - Verifies every file against archive.org's MD5 and
rem     auto-retries on mismatch
rem
rem   Requires: curl.exe (built into Windows 10 1803+/11),
rem             certutil.exe and powershell.exe (both built
rem             into Windows). No other files are needed -
rem             everything lives in this one .bat.
rem ===========================================================

cd /d "%~dp0"
set "DESTROOT=%CD%"
set "IA_ID=wcn-audiobooks"
set "MANIFEST_URL=https://archive.org/download/%IA_ID%/%IA_ID%_files.xml"
set "MAXRETRY=3"
set "LOGFILE=%DESTROOT%\Audiobooks-Download.log"

cls
echo ===========================================================
echo   WCN AUDIOBOOKS DOWNLOADER
echo ===========================================================
echo.
echo   Downloads root : %DESTROOT%
echo   Archive item   : %IA_ID%
echo.
echo   - Fetches the current list of audiobook MP3 files from
echo     archive.org and lets you pick which to download.
echo   - Resume-safe: closing this window mid-download and
echo     re-running will continue where it left off.
echo   - Every finished file is checked against archive.org's
echo     MD5 hash; a mismatch is deleted and retried automatically.
echo.
pause

rem ===========================================================
rem   CHECK REQUIRED TOOLS
rem ===========================================================
where curl >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: curl.exe was not found on this system.
    echo curl.exe ships with Windows 10 ^(1803+^) and Windows 11.
    echo If you are on an older Windows, install curl from
    echo https://curl.se/windows/ and run this again.
    echo.
    pause
    exit /b 1
)

where certutil >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: certutil.exe was not found. It is required to
    echo verify downloaded files and should be built into Windows.
    echo.
    pause
    exit /b 1
)

where powershell >nul 2>&1
if errorlevel 1 (
    echo.
    echo ERROR: powershell.exe was not found. It is required to
    echo read the audiobook list from archive.org and should be
    echo built into Windows.
    echo.
    pause
    exit /b 1
)

:refresh
rem ===========================================================
rem   FETCH FILE MANIFEST FROM ARCHIVE.ORG
rem ===========================================================
set "MANIFEST=%TEMP%\wcn_ab_manifest.xml"
set "LISTOUT=%TEMP%\wcn_ab_list.txt"
set "TMPPS=%TEMP%\wcn_ab_parse.ps1"

echo.
echo Fetching audiobook list from archive.org ...
curl -s -L -o "%MANIFEST%" "%MANIFEST_URL%"

if not exist "%MANIFEST%" (
    echo.
    echo ERROR: could not reach archive.org. Check your internet
    echo connection and try again.
    echo.
    pause
    goto :eof
)

set "MANSIZE=0"
for %%F in ("%MANIFEST%") do set "MANSIZE=%%~zF"
if !MANSIZE! LSS 50 (
    echo.
    echo ERROR: archive item "%IA_ID%" was not found, or has no
    echo files yet. Double check the identifier and try again.
    echo.
    del "%MANIFEST%" 2>nul
    pause
    goto :eof
)

rem ---- write the small PowerShell manifest parser ----
> "%TMPPS%" echo param([string]$XmlPath,[string]$OutPath)
>>"%TMPPS%" echo [xml]$xml = Get-Content -Raw -Path $XmlPath
>>"%TMPPS%" echo $entries = $xml.files.file ^| Where-Object { $_.name -like '*.mp3' } ^| Sort-Object { $_.name }
>>"%TMPPS%" echo $lines = foreach ($f in $entries) {
>>"%TMPPS%" echo   $bytes = [int64]$f.size
>>"%TMPPS%" echo   if ($bytes -ge 1GB) { $sizeStr = "{0:N2} GB" -f ($bytes/1GB) } else { $sizeStr = "{0:N1} MB" -f ($bytes/1MB) }
>>"%TMPPS%" echo   "$($f.name)^|$($f.size)^|$($f.md5)^|$sizeStr"
>>"%TMPPS%" echo }
>>"%TMPPS%" echo Set-Content -Path $OutPath -Value $lines -Encoding ASCII

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%TMPPS%" -XmlPath "%MANIFEST%" -OutPath "%LISTOUT%"
del "%TMPPS%" 2>nul

if not exist "%LISTOUT%" (
    echo.
    echo ERROR: could not parse the audiobook list.
    echo.
    pause
    goto :eof
)

rem ===========================================================
rem   LOAD LIST INTO ARRAYS
rem ===========================================================
set "COUNT=0"
for /f "usebackq tokens=1-4 delims=|" %%A in ("%LISTOUT%") do (
    set /a COUNT+=1
    set "NAME_!COUNT!=%%A"
    set "SIZE_!COUNT!=%%B"
    set "MD5_!COUNT!=%%C"
    set "SIZESTR_!COUNT!=%%D"
)

if !COUNT! EQU 0 (
    echo.
    echo No .mp3 files were found in this archive item yet.
    echo.
    pause
    goto :eof
)

:menu
cls
echo ===========================================================
echo   WCN AUDIOBOOKS DOWNLOADER  -  !COUNT! files available
echo ===========================================================
echo.
for /L %%N in (1,1,!COUNT!) do (
    call echo   %%N^)  !NAME_%%N!   ^(!SIZESTR_%%N!^)
)
echo.
echo   Enter a number, a comma list ^(e.g. 1,3,5^), ALL, R to
echo   refresh the list, or Q to quit.
set /p "CHOICE=Selection: "

if /I "!CHOICE!"=="Q" goto :eof
if /I "!CHOICE!"=="R" goto refresh
if "!CHOICE!"=="" goto menu

set "QUEUE="
if /I "!CHOICE!"=="ALL" (
    for /L %%N in (1,1,!COUNT!) do set "QUEUE=!QUEUE! %%N"
) else (
    set "CHOICELIST=!CHOICE:,= !"
    for %%X in (!CHOICELIST!) do (
        set "VALID=1"
        for /f "delims=0123456789" %%Z in ("%%X") do set "VALID=0"
        if "!VALID!"=="0" (
            echo   Skipping invalid choice: %%X
        ) else if %%X LSS 1 (
            echo   Skipping out-of-range choice: %%X
        ) else if %%X GTR !COUNT! (
            echo   Skipping out-of-range choice: %%X
        ) else (
            set "QUEUE=!QUEUE! %%X"
        )
    )
)

if "!QUEUE!"=="" (
    echo.
    echo No valid items selected.
    echo.
    pause
    goto menu
)

rem ===========================================================
rem   DOWNLOAD QUEUE
rem ===========================================================
set "QN=0"
for %%X in (!QUEUE!) do set /a QN+=1
set "QI=0"

for %%X in (!QUEUE!) do (
    set /a QI+=1
    call :download %%X !QI! !QN!
)

echo.
echo ===========================================================
echo   Queue complete. Full record in:
echo   !LOGFILE!
echo ===========================================================
echo.
pause
goto menu

rem ===========================================================
rem   SUBROUTINE: DOWNLOAD + VERIFY ONE FILE
rem   %1 = index into the arrays   %2 = position in queue   %3 = queue size
rem ===========================================================
:download
set "IDX=%~1"
set "QI=%~2"
set "QN=%~3"
set "FNAME=!NAME_%IDX%!"
set "FSIZE=!SIZE_%IDX%!"
set "FMD5=!MD5_%IDX%!"
set "FSIZESTR=!SIZESTR_%IDX%!"
set "OUTFILE=%DESTROOT%\!FNAME!"
rem archive.org filenames often contain spaces (chapter titles) -
rem HTTP requests can't carry raw spaces, so encode them for the URL
rem while keeping the original name for the saved local file.
set "URLNAME=!FNAME: =%20!"
set "URL=https://archive.org/download/%IA_ID%/!URLNAME!"

echo.
echo -----------------------------------------------------------
echo [!QI!/!QN!] !FNAME!  ^(!FSIZESTR!^)
echo -----------------------------------------------------------

set "ATTEMPT=0"

:dl_attempt
set /a ATTEMPT+=1

set "LOCALSIZE=0"
if exist "!OUTFILE!" for %%F in ("!OUTFILE!") do set "LOCALSIZE=%%~zF"

if "!LOCALSIZE!"=="!FSIZE!" (
    echo Already downloaded - verifying...
) else (
    echo Downloading ^(attempt !ATTEMPT!/%MAXRETRY%, resume-safe^)...
    curl -L -C - --retry 3 --retry-delay 2 -# -o "!OUTFILE!" "!URL!"
)

set "GOTHASH="
if exist "!OUTFILE!" (
    for /f "tokens=* delims= " %%H in ('certutil -hashfile "!OUTFILE!" MD5 ^| findstr /v "hash CertUtil"') do set "GOTHASH=%%H"
    set "GOTHASH=!GOTHASH: =!"
)

if /I "!GOTHASH!"=="!FMD5!" (
    echo VERIFIED OK: !FNAME!
    >>"!LOGFILE!" echo %DATE% %TIME%  OK    !FNAME!  md5=!GOTHASH!
) else (
    echo Hash check failed for !FNAME! ^(attempt !ATTEMPT!^)
    if exist "!OUTFILE!" del "!OUTFILE!" 2>nul
    if !ATTEMPT! LSS %MAXRETRY% (
        goto dl_attempt
    ) else (
        echo FAILED after %MAXRETRY% attempts: !FNAME!
        >>"!LOGFILE!" echo %DATE% %TIME%  FAIL  !FNAME!
    )
)
goto :eof