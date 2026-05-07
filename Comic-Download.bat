@echo off
title WENDELL'S DIARY — Comic Archive Mirror
setlocal enabledelayedexpansion

:: =========================================================
::  INITIALISE WORKING DIRECTORY
:: =========================================================
cd /d "%~dp0"
set "DESTROOT=%CD%"

:: =========================================================
::  ARCHIVE ITEM
:: =========================================================
set "IA_ID=wendells-diary-comic"
set "URL=https://archive.org/download/%IA_ID%/"
set "OUTROOT=%DESTROOT%\%IA_ID%"

:: =========================================================
::  INTRO
:: =========================================================
cls
echo WENDELL'S DIARY — Comic Archive Mirror
echo.
echo  A bard-core, single-panel comic series chronicling the whimsical
echo  and philosophical life of Wendell — a long-haired bard armed with
echo  a lyre, an Australian flag, and a mission of meaning.
echo.
echo  Alongside his loyal dog Sophia (Chief of Defence), Wendell navigates
echo  themes of emergence, politics, and identity with satire, sincerity,
echo  and mythological flair. A growing cast of plush advisors, rivals,
echo  and guardians transforms everyday moments into grand, ongoing mythology.
echo.
echo  368 panels. All CC0 Public Domain. All love reserved.
echo.
echo  Downloads to: %OUTROOT%
echo.
echo  RESUME-SAFE: Existing files are checked by size.
echo  Complete files are skipped. Partial files are redownloaded.
echo.
echo =========================================================
echo  What would you like to download?
echo.
echo   1) PNGs only — all 368 individual comic panels
echo   2) PNGs + ZIP — all panels plus the full compressed archive
echo              (one ZIP containing all 368 panels bundled together)
echo.
echo  Note: This script (.bat) will also be downloaded automatically
echo        alongside your chosen option.
echo.
echo =========================================================
echo.

:askChoice
set /p CHOICE=Enter 1 or 2: 

if "%CHOICE%"=="1" (
  set "DL_ZIP=0"
  goto :startDownload
)
if "%CHOICE%"=="2" (
  set "DL_ZIP=1"
  goto :startDownload
)
echo Invalid choice. Please enter 1 or 2.
goto :askChoice

:: =========================================================
::  START DOWNLOAD
:: =========================================================
:startDownload
echo.
if "%DL_ZIP%"=="1" (
  echo Downloading PNGs, ZIP, and BAT files...
) else (
  echo Downloading PNGs and BAT files...
)
echo.

if not exist "%OUTROOT%" mkdir "%OUTROOT%"

:: =========================================================
::  WRITE POWERSHELL MIRROR SCRIPT
:: =========================================================
set "TMPPS=%OUTROOT%\_comic_mirror_tmp.ps1"

> "%TMPPS%" echo param([string]$Url,[string]$OutDir,[string]$DlZip)
>>"%TMPPS%" echo $wc = New-Object System.Net.WebClient
>>"%TMPPS%" echo $indexHtml = $wc.DownloadString($Url)
>>"%TMPPS%" echo $pattern = 'href="([^"]+)"'
>>"%TMPPS%" echo $matches_ = [regex]::Matches($indexHtml, $pattern)
>>"%TMPPS%" echo $links = $matches_ ^| ForEach-Object { $_.Groups[1].Value }
>>"%TMPPS%" echo $downloaded   = 0
>>"%TMPPS%" echo $skipped      = 0
>>"%TMPPS%" echo $redownloaded = 0
>>"%TMPPS%" echo $filtered     = 0
>>"%TMPPS%" echo foreach ($l in $links) {
>>"%TMPPS%" echo   if ($l.StartsWith("/") -or $l.StartsWith("?") -or $l.StartsWith("http") -or $l -eq "/" -or $l.EndsWith("/")) { continue }
>>"%TMPPS%" echo   $ext = [System.IO.Path]::GetExtension($l).ToLower()
>>"%TMPPS%" echo   if ($ext -eq '.jpg' -or $ext -eq '.jpeg') { $filtered++; continue }
>>"%TMPPS%" echo   if ($ext -ne '.png' -and $ext -ne '.zip' -and $ext -ne '.bat') { $filtered++; continue }
>>"%TMPPS%" echo   if ($ext -eq '.zip' -and $DlZip -ne '1') { $filtered++; continue }
>>"%TMPPS%" echo   $decoded = [System.Uri]::UnescapeDataString($l)
>>"%TMPPS%" echo   $clean   = $decoded -replace '[\\/:*?"<>|]','' -replace ' ','-'
>>"%TMPPS%" echo   $of      = Join-Path $OutDir $clean
>>"%TMPPS%" echo   $fu      = ($Url.TrimEnd('/') + '/' + $l)
>>"%TMPPS%" echo   if (Test-Path $of) {
>>"%TMPPS%" echo     try {
>>"%TMPPS%" echo       $req = [System.Net.WebRequest]::Create($fu)
>>"%TMPPS%" echo       $req.Method = "HEAD"
>>"%TMPPS%" echo       $resp = $req.GetResponse()
>>"%TMPPS%" echo       $serverSize = $resp.ContentLength
>>"%TMPPS%" echo       $resp.Close()
>>"%TMPPS%" echo       $localSize = (Get-Item $of).Length
>>"%TMPPS%" echo       if ($localSize -eq $serverSize) {
>>"%TMPPS%" echo         Write-Host "SKIP (complete) $clean"
>>"%TMPPS%" echo         $skipped++
>>"%TMPPS%" echo         continue
>>"%TMPPS%" echo       } else {
>>"%TMPPS%" echo         Write-Host "REDOWNLOAD (size mismatch: local=$localSize server=$serverSize) $clean"
>>"%TMPPS%" echo         Remove-Item $of -Force
>>"%TMPPS%" echo         $redownloaded++
>>"%TMPPS%" echo       }
>>"%TMPPS%" echo     } catch {
>>"%TMPPS%" echo       Write-Host "WARN (could not check size, skipping) $clean"
>>"%TMPPS%" echo       $skipped++
>>"%TMPPS%" echo       continue
>>"%TMPPS%" echo     }
>>"%TMPPS%" echo   }
>>"%TMPPS%" echo   Write-Host "GET  $clean"
>>"%TMPPS%" echo   try {
>>"%TMPPS%" echo     $wc.DownloadFile($fu, $of)
>>"%TMPPS%" echo     $downloaded++
>>"%TMPPS%" echo   } catch {
>>"%TMPPS%" echo     Write-Host "FAIL $fu : $_"
>>"%TMPPS%" echo   }
>>"%TMPPS%" echo }
>>"%TMPPS%" echo Write-Host ""
>>"%TMPPS%" echo Write-Host "Done.  Downloaded: $downloaded  Redownloaded (size mismatch): $redownloaded  Skipped (complete): $skipped  Filtered (other types): $filtered"

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%TMPPS%" -Url "%URL%" -OutDir "%OUTROOT%" -DlZip "%DL_ZIP%"

del "%TMPPS%" 2>nul

echo.
echo =========================================================
echo  Mirror complete. Files are in:
echo  %OUTROOT%
echo  Run again at any time to resume or verify.
echo =========================================================
echo.
pause