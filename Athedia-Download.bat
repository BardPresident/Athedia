@echo off
title ATHEDIA - Archive Mirror (The Wending Road / Cognitive Uploads)
setlocal enabledelayedexpansion

:: =========================================================
::  INITIALISE WORKING DIRECTORY
:: =========================================================
cd /d "%~dp0"
set "DESTROOT=%CD%"
set "IA_ID=athedia"
set "URL=https://archive.org/download/%IA_ID%/"
set "OUTROOT=%DESTROOT%\%IA_ID%"

:: =========================================================
::  VISIBLE INTRO
:: =========================================================
cls
echo ATHEDIA - Archive Mirror
echo Archive.org: https://archive.org/details/athedia
echo.
echo  The Athedia archive contains the complete technical
echo  infrastructure and core structural framework developed
echo  to support a sprawling digital legacy. It serves as a
echo  comprehensive repository for the underlying systems,
echo  source files, and deployment configurations used to
echo  maintain a vast collection of literary and musical works.
echo  By consolidating these assets into a single, resilient
echo  environment, the infrastructure ensures that the
echo  architectural "Front Door" of this body of work remains
echo  accessible and functional as a permanent, self-sustaining
echo  transmission.
echo.
echo  WHAT THIS SCRIPT DOES
echo  ---------------------
echo  - Mirrors the Athedia Internet Archive item into a local
echo    subfolder called "athedia" under this script's directory.
echo  - Downloads ZIP and BAT files only.
echo  - Skips any file that already exists locally (resume-safe).
echo  - Run it again at any time to pick up where you left off.
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
::  WRITE POWERSHELL MIRROR SCRIPT
:: =========================================================
set "TMPPS=%OUTROOT%\_athedia_mirror_tmp.ps1"

> "%TMPPS%" echo param([string]$Url,[string]$OutDir)
>>"%TMPPS%" echo $wc = New-Object System.Net.WebClient
>>"%TMPPS%" echo $allowed = @('.zip','.bat')
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
>>"%TMPPS%" echo   if (Test-Path $of) {
>>"%TMPPS%" echo     $info = Get-Item $of
>>"%TMPPS%" echo     if ($info.Length -gt 0) { Write-Host "SKIP (exists) $clean"; $skipped++; continue }
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
>>"%TMPPS%" echo Write-Host "Done. Downloaded: $downloaded  Skipped (already local): $skipped  Filtered (wrong type): $filtered"

:: =========================================================
::  RUN THE SCRIPT
:: =========================================================
echo.
echo Mirroring Athedia from Internet Archive...
echo Only .zip / .bat files will be saved.
echo Existing files will be skipped (resume-safe).
echo.

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%TMPPS%" -Url "%URL%" -OutDir "%OUTROOT%"

del "%TMPPS%" 2>nul

echo.
echo =========================================================
echo  Mirror complete. Files are in:
echo  %OUTROOT%
echo  Run this script again at any time to resume / refresh.
echo =========================================================
echo.
pause