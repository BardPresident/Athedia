@echo off
title WIKKKAN - Books Mirror (The Wending Road / Wendell Charles NeSmith)
setlocal enabledelayedexpansion

:: =========================================================
::  INITIALISE WORKING DIRECTORY
:: =========================================================
cd /d "%~dp0"
set "DESTROOT=%CD%"
set "IA_ID=wikkkan"
set "URL=https://archive.org/download/%IA_ID%/"
set "OUTROOT=%DESTROOT%\%IA_ID%"

:: =========================================================
::  VISIBLE INTRO
:: =========================================================
cls
echo WIKKKAN - Books Mirror
echo Archive.org: https://archive.org/details/wikkkan
echo.
echo  Books written and compiled by Wendell Charles NeSmith that
echo  explore philosophy, spirituality, psychology, politics, and
echo  personal transformation through both fiction and non-fiction
echo  narratives. These works trace an ongoing intellectual and
echo  emotional journey, challenging conventional beliefs while
echo  inviting readers to question authority, examine their own
echo  values, and search for deeper meaning in everyday life.
echo  Together, they form a connected body of work documenting the
echo  evolution of one author's ideas about consciousness, society,
echo  freedom, love, and the future of humanity.
echo.
echo  OUTPUT FOLDER
echo  -------------
echo  %OUTROOT%
echo.

:: =========================================================
::  MODE SELECTION
:: =========================================================
echo  =========================================================
echo   DOWNLOAD MODE
echo  =========================================================
echo.
echo   1) WIPE AND REDOWNLOAD EVERYTHING (always get latest)
echo   2) RESUME (skip files already downloaded)
echo.
set /p MODE=Enter 1 or 2: 

if "%MODE%"=="1" goto wipe
if "%MODE%"=="2" goto resume
echo Invalid choice. Please enter 1 or 2.
pause
goto :eof

:: =========================================================
::  WIPE MODE
:: =========================================================
:wipe
echo.
echo Mode: WIPE AND REDOWNLOAD
echo Clearing existing TXT and BAT files from local folder...
if not exist "%OUTROOT%" mkdir "%OUTROOT%"
del /Q "%OUTROOT%\*.txt" 2>nul
del /Q "%OUTROOT%\*.bat" 2>nul
echo Done.
echo.
set "RESUME_MODE=0"
goto run

:: =========================================================
::  RESUME MODE
:: =========================================================
:resume
echo.
echo Mode: RESUME (existing files will be skipped)
echo.
if not exist "%OUTROOT%" mkdir "%OUTROOT%"
set "RESUME_MODE=1"
goto run

:: =========================================================
::  WRITE AND RUN POWERSHELL MIRROR SCRIPT
:: =========================================================
:run
set "TMPPS=%OUTROOT%\_wikkkan_mirror_tmp.ps1"

> "%TMPPS%" echo param([string]$Url,[string]$OutDir,[string]$ResumeMode)
>>"%TMPPS%" echo $wc = New-Object System.Net.WebClient
>>"%TMPPS%" echo $allowed = @('.txt','.bat')
>>"%TMPPS%" echo $indexHtml = $wc.DownloadString($Url)
>>"%TMPPS%" echo $pattern = 'href="([^"]+)"'
>>"%TMPPS%" echo $matches_ = [regex]::Matches($indexHtml, $pattern)
>>"%TMPPS%" echo $links = $matches_ ^| ForEach-Object { $_.Groups[1].Value }
>>"%TMPPS%" echo $downloaded = 0
>>"%TMPPS%" echo $skipped    = 0
>>"%TMPPS%" echo $filtered   = 0
>>"%TMPPS%" echo foreach ($l in $links) {
>>"%TMPPS%" echo   if ($l.StartsWith("/") -or $l.StartsWith("?") -or $l.StartsWith("http") -or $l -eq "/" -or $l.EndsWith("/")) { continue }
>>"%TMPPS%" echo   $ext = [System.IO.Path]::GetExtension($l).ToLower()
>>"%TMPPS%" echo   if ($allowed -notcontains $ext) { $filtered++; continue }
>>"%TMPPS%" echo   $decoded = [System.Uri]::UnescapeDataString($l)
>>"%TMPPS%" echo   $clean   = $decoded -replace '[\\/:*?"<>|]',''
>>"%TMPPS%" echo   $of      = Join-Path $OutDir $clean
>>"%TMPPS%" echo   if ($ResumeMode -eq "1") {
>>"%TMPPS%" echo     if (Test-Path $of) {
>>"%TMPPS%" echo       $info = Get-Item $of
>>"%TMPPS%" echo       if ($info.Length -gt 0) { Write-Host "SKIP (exists) $clean"; $skipped++; continue }
>>"%TMPPS%" echo     }
>>"%TMPPS%" echo   }
>>"%TMPPS%" echo   $fu = ($Url.TrimEnd('/') + '/' + $l)
>>"%TMPPS%" echo   Write-Host "GET  $clean"
>>"%TMPPS%" echo   try {
>>"%TMPPS%" echo     $wc.DownloadFile($fu, $of)
>>"%TMPPS%" echo     $downloaded++
>>"%TMPPS%" echo   } catch {
>>"%TMPPS%" echo     Write-Host "FAIL $fu : $_"
>>"%TMPPS%" echo   }
>>"%TMPPS%" echo }
>>"%TMPPS%" echo Write-Host "Done. Downloaded: $downloaded  Skipped: $skipped  Filtered: $filtered"

echo Mirroring WIKKKAN books from Internet Archive...
echo Only .txt / .bat files will be saved.
echo.

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%TMPPS%" -Url "%URL%" -OutDir "%OUTROOT%" -ResumeMode "%RESUME_MODE%"

del "%TMPPS%" 2>nul

echo.
echo =========================================================
echo  Mirror complete. Files are in:
echo  %OUTROOT%
echo  Run this script again at any time.
echo =========================================================
echo.
pause