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
echo  WHAT THIS SCRIPT DOES
echo  ---------------------
echo  - Mirrors the WIKKKAN Internet Archive item into a local
echo    subfolder called "wikkkan" under this script's directory.
echo  - Downloads TXT and BAT files only.
echo  - DELETES all existing local TXT and BAT files first, then
echo    redownloads everything fresh. This ensures updated books
echo    always replace older local copies.
echo  - Run it again at any time to get the latest versions.
echo.
echo  OUTPUT FOLDER
echo  -------------
echo  %OUTROOT%
echo.
pause

:: =========================================================
::  CREATE OUTPUT FOLDER
:: =========================================================
if not exist "%OUTROOT%" mkdir "%OUTROOT%"

:: =========================================================
::  DELETE EXISTING TXT AND BAT FILES
:: =========================================================
echo.
echo Clearing existing TXT and BAT files from local folder...
del /Q "%OUTROOT%\*.txt" 2>nul
del /Q "%OUTROOT%\*.bat" 2>nul
echo Done.
echo.

:: =========================================================
::  WRITE POWERSHELL MIRROR SCRIPT
:: =========================================================
set "TMPPS=%OUTROOT%\_wikkkan_mirror_tmp.ps1"

> "%TMPPS%" echo param([string]$Url,[string]$OutDir)
>>"%TMPPS%" echo $wc = New-Object System.Net.WebClient
>>"%TMPPS%" echo $allowed = @('.txt','.bat')
>>"%TMPPS%" echo.
>>"%TMPPS%" echo # Fetch the directory index
>>"%TMPPS%" echo Write-Host "Fetching index from $Url ..."
>>"%TMPPS%" echo $indexHtml = $wc.DownloadString($Url)
>>"%TMPPS%" echo.
>>"%TMPPS%" echo # Extract all href values
>>"%TMPPS%" echo $pattern = 'href="([^"]+)"'
>>"%TMPPS%" echo $matches_ = [regex]::Matches($indexHtml, $pattern)
>>"%TMPPS%" echo $links = $matches_ ^| ForEach-Object { $_.Groups[1].Value }
>>"%TMPPS%" echo.
>>"%TMPPS%" echo $downloaded = 0
>>"%TMPPS%" echo $filtered   = 0
>>"%TMPPS%" echo.
>>"%TMPPS%" echo foreach ($l in $links) {
>>"%TMPPS%" echo   # Skip navigation / external / directory links
>>"%TMPPS%" echo   if ($l.StartsWith("/") -or $l.StartsWith("?") -or $l.StartsWith("http") -or $l -eq "/" -or $l.EndsWith("/")) { continue }
>>"%TMPPS%" echo.
>>"%TMPPS%" echo   # Check extension whitelist
>>"%TMPPS%" echo   $ext = [System.IO.Path]::GetExtension($l).ToLower()
>>"%TMPPS%" echo   if ($allowed -notcontains $ext) { $filtered++; continue }
>>"%TMPPS%" echo.
>>"%TMPPS%" echo   $decoded = [System.Uri]::UnescapeDataString($l)
>>"%TMPPS%" echo   $clean   = $decoded -replace '[\\/:*?"<>|]',''
>>"%TMPPS%" echo   $of      = Join-Path $OutDir $clean
>>"%TMPPS%" echo.
>>"%TMPPS%" echo   $fu = ($Url.TrimEnd('/') + '/' + $l)
>>"%TMPPS%" echo   Write-Host "GET  $clean"
>>"%TMPPS%" echo   try {
>>"%TMPPS%" echo     $wc.DownloadFile($fu, $of)
>>"%TMPPS%" echo     $downloaded++
>>"%TMPPS%" echo   } catch {
>>"%TMPPS%" echo     Write-Host "FAIL $fu : $_"
>>"%TMPPS%" echo   }
>>"%TMPPS%" echo }
>>"%TMPPS%" echo.
>>"%TMPPS%" echo Write-Host ""
>>"%TMPPS%" echo Write-Host "Done. Downloaded: $downloaded  Filtered (wrong type): $filtered"

:: =========================================================
::  RUN THE SCRIPT
:: =========================================================
echo Mirroring WIKKKAN books from Internet Archive...
echo Only .txt / .bat files will be saved.
echo All files are downloaded fresh every run.
echo.

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%TMPPS%" -Url "%URL%" -OutDir "%OUTROOT%"

del "%TMPPS%" 2>nul

echo.
echo =========================================================
echo  Mirror complete. Files are in:
echo  %OUTROOT%
echo  Run this script again at any time to get latest versions.
echo =========================================================
echo.
pause