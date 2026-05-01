@echo off
title ATHEDEN - Archive Mirror (The Wending Road / Cognitive Uploads)
setlocal enabledelayedexpansion

:: =========================================================
::  INITIALISE WORKING DIRECTORY
:: =========================================================
cd /d "%~dp0"
set "DESTROOT=%CD%"
set "IA_ID=atheden"
set "URL=https://archive.org/download/%IA_ID%/"
set "OUTROOT=%DESTROOT%\%IA_ID%"

:: =========================================================
::  VISIBLE INTRO
:: =========================================================
cls
echo ATHEDEN - Archive Mirror
echo Archive.org: https://archive.org/details/atheden
echo.
echo  Ivory and Wendell sing. Their voices carry the great love
echo  stories of myth, scripture, and soul - from underworld
echo  descents to impossible reunions, from stone turned to flesh,
echo  from grief transmuted into gold. Each song is a prayer, each
echo  melody a thread pulled from the Loom of creation. These are
echo  not performances; they are transmissions. Moving through
echo  crowns, crosses, and underworlds with the same vow: to give
echo  sound to love that refuses to die, love that returns from
echo  Hades, love that finds what was lost and binds souls across
echo  lifetimes.
echo  Kry Kry Kry. The tears are the most powerful magicka.
echo.
echo  WHAT THIS SCRIPT DOES
echo  ---------------------
echo  - Mirrors the Atheden Internet Archive item into a local
echo    subfolder called "atheden" under this script's directory.
echo  - Downloads MP3, PNG, TXT, and BAT files only.
echo  - TXT files (lyrics) are deleted and redownloaded fresh
echo    every run so updates are always picked up.
echo  - MP3, PNG, and BAT files are skipped if already local
echo    (resume-safe).
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
::  DELETE EXISTING TXT FILES (lyrics always refresh)
:: =========================================================
echo Clearing existing TXT files for fresh lyrics download...
del /Q "%OUTROOT%\*.txt" 2>nul
echo Done.
echo.

:: =========================================================
::  WRITE POWERSHELL MIRROR SCRIPT
:: =========================================================
set "TMPPS=%OUTROOT%\_atheden_mirror_tmp.ps1"

> "%TMPPS%" echo param([string]$Url,[string]$OutDir)
>>"%TMPPS%" echo $wc = New-Object System.Net.WebClient
>>"%TMPPS%" echo $allowed = @('.mp3','.png','.txt','.bat')
>>"%TMPPS%" echo $alwaysFresh = @('.txt')
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
>>"%TMPPS%" echo $skipped    = 0
>>"%TMPPS%" echo $filtered   = 0
>>"%TMPPS%" echo.
>>"%TMPPS%" echo # First pass: collect all MP3 basenames to skip matching PNGs
>>"%TMPPS%" echo $mp3Bases = @{}
>>"%TMPPS%" echo foreach ($l in $links) {
>>"%TMPPS%" echo   if ([System.IO.Path]::GetExtension($l).ToLower() -eq '.mp3') {
>>"%TMPPS%" echo     $mp3Bases[[System.IO.Path]::GetFileNameWithoutExtension($l).ToLower()] = $true
>>"%TMPPS%" echo   }
>>"%TMPPS%" echo }
>>"%TMPPS%" echo.
>>"%TMPPS%" echo foreach ($l in $links) {
>>"%TMPPS%" echo   # Skip navigation / external / directory links
>>"%TMPPS%" echo   if ($l.StartsWith("/") -or $l.StartsWith("?") -or $l.StartsWith("http") -or $l -eq "/" -or $l.EndsWith("/")) { continue }
>>"%TMPPS%" echo.
>>"%TMPPS%" echo   # Check extension whitelist
>>"%TMPPS%" echo   $ext = [System.IO.Path]::GetExtension($l).ToLower()
>>"%TMPPS%" echo   if ($allowed -notcontains $ext) { $filtered++; continue }
>>"%TMPPS%" echo.
>>"%TMPPS%" echo   # Skip Archive.org auto-generated spectrograms
>>"%TMPPS%" echo   if ($l -like '*_spectrogram*') { $filtered++; continue }
>>"%TMPPS%" echo.
>>"%TMPPS%" echo   # Skip PNGs that share a basename with an MP3 (Archive.org duplicates)
>>"%TMPPS%" echo   if ($ext -eq '.png') {
>>"%TMPPS%" echo     $base = [System.IO.Path]::GetFileNameWithoutExtension($l).ToLower()
>>"%TMPPS%" echo     if ($mp3Bases.ContainsKey($base)) { $filtered++; continue }
>>"%TMPPS%" echo   }
>>"%TMPPS%" echo.
>>"%TMPPS%" echo   $decoded = [System.Uri]::UnescapeDataString($l)
>>"%TMPPS%" echo   $clean   = $decoded -replace '[\\/:*?"<>|]',''
>>"%TMPPS%" echo   $of      = Join-Path $OutDir $clean
>>"%TMPPS%" echo.
>>"%TMPPS%" echo   # Resume: skip existing files UNLESS this type is always refreshed
>>"%TMPPS%" echo   if ($alwaysFresh -notcontains $ext) {
>>"%TMPPS%" echo     if (Test-Path $of) {
>>"%TMPPS%" echo       $info = Get-Item $of
>>"%TMPPS%" echo       if ($info.Length -gt 0) { Write-Host "SKIP (exists) $clean"; $skipped++; continue }
>>"%TMPPS%" echo     }
>>"%TMPPS%" echo   }
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
>>"%TMPPS%" echo Write-Host "Done. Downloaded: $downloaded  Skipped (already local): $skipped  Filtered (wrong type): $filtered"

:: =========================================================
::  RUN THE SCRIPT
:: =========================================================
echo.
echo Mirroring Atheden from Internet Archive...
echo TXT (lyrics) always redownloaded fresh.
echo MP3 / PNG / BAT skipped if already local (resume-safe).
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