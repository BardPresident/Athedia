@echo off
title AUDIOBOOKS - Archive Mirror
setlocal enabledelayedexpansion

:: =========================================================
::  INITIALISE WORKING DIRECTORY
:: =========================================================
cd /d "%~dp0"
set "DESTROOT=%CD%"

:: =========================================================
::  VISIBLE INTRO
:: =========================================================
cls
echo AUDIOBOOKS
echo Archive Mirror — https://archive.org/download/wcn-books
echo.
echo  WHAT THIS SCRIPT DOES
echo  ---------------------
echo  - Downloads MP3, PDF, DOCX, EPUB, MOBI, and BAT files only.
echo  - RESUME-SAFE with size verification: if a file exists
echo    locally, its size is checked against the server. A
echo    complete match = skip. A mismatch (partial / corrupt)
echo    = delete and redownload cleanly.
echo  - All files download into one folder: wcn-books
echo.
echo Downloads root: %DESTROOT%
echo.
pause

:: =========================================================
::  ITEM SETUP
:: =========================================================
set "IA_ID=wcn-books"
set "OUTROOT=%DESTROOT%\%IA_ID%"
if not exist "%OUTROOT%" mkdir "%OUTROOT%"

set "URL=https://archive.org/download/%IA_ID%/"

:: =========================================================
::  WRITE POWERSHELL MIRROR SCRIPT
:: =========================================================
set "TMPPS=%OUTROOT%\_audiobooks_mirror_tmp.ps1"

> "%TMPPS%" echo param([string]$Url,[string]$OutDir)
>>"%TMPPS%" echo $wc = New-Object System.Net.WebClient
>>"%TMPPS%" echo $indexHtml = $wc.DownloadString($Url)
>>"%TMPPS%" echo $pattern = 'href="([^"]+)"'
>>"%TMPPS%" echo $matches_ = [regex]::Matches($indexHtml, $pattern)
>>"%TMPPS%" echo $links = $matches_ ^| ForEach-Object { $_.Groups[1].Value }
>>"%TMPPS%" echo $allowedExt = @('.mp3','.pdf','.docx','.epub','.mobi','.bat')
>>"%TMPPS%" echo $downloaded = 0
>>"%TMPPS%" echo $skipped    = 0
>>"%TMPPS%" echo $redownloaded = 0
>>"%TMPPS%" echo $filtered   = 0
>>"%TMPPS%" echo foreach ($l in $links) {
>>"%TMPPS%" echo   if ($l.StartsWith("/") -or $l.StartsWith("?") -or $l.StartsWith("http") -or $l -eq "/" -or $l.EndsWith("/")) { continue }
>>"%TMPPS%" echo   $ext = [System.IO.Path]::GetExtension($l).ToLower()
>>"%TMPPS%" echo   if ($allowedExt -notcontains $ext) { $filtered++; continue }
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
>>"%TMPPS%" echo Write-Host "Done. Downloaded: $downloaded  Redownloaded (size mismatch): $redownloaded  Skipped (complete): $skipped  Filtered: $filtered"

echo Mirroring MP3 / PDF / DOCX / EPUB / MOBI / BAT files from Internet Archive...
echo Files will be checked by size. Partial downloads will be retried.
echo.

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%TMPPS%" -Url "%URL%" -OutDir "%OUTROOT%"

del "%TMPPS%" 2>nul

echo.
echo =========================================================
echo  Mirror complete. Files are in:
echo  %OUTROOT%
echo  Run again at any time to resume or verify.
echo =========================================================
echo.
pause