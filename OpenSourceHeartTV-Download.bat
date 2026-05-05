@echo off
title OPEN SOURCE HEART TV - Archive Mirror (The Wending Road)
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
echo OPEN SOURCE HEART TV
echo Archive Mirror — The Wending Road
echo.
echo  A life-long sequence of films, series, and courses by
echo  Wendell Charles NeSmith — cognitive uploads spanning
echo  more than a decade, released entirely as CC0 Public Domain.
echo.
echo  From the earliest 2-4 hour homeless adventure epics
echo  to the mid-length REPUBLICKA diary uploads, every work
echo  is an attempt to externalise mind, memory, and philosophy
echo  into media. All eras. All love. All yours.
echo.
echo  WHAT THIS SCRIPT DOES
echo  ---------------------
echo  - Presents all TV / film / course items chronologically.
echo  - Downloads MP4 files only.
echo  - RESUME-SAFE with size verification: if a file exists
echo    locally, its size is checked against the server. A
echo    complete match = skip. A mismatch (partial / corrupt)
echo    = delete and redownload cleanly.
echo  - Each item downloads into its own subfolder.
echo.
echo  Downloads root: %DESTROOT%
echo.
pause

:: =========================================================
::  DEFINE ITEMS IN CHRONOLOGICAL ORDER
:: =========================================================
set "COUNT=0"

call :addItem "OSU Movies (2012 - compression node: many films)"              "OSUMovies"
call :addItem "The Meaning of Life (March 9, 2012)"                           "TheMeaningOfLife666"
call :addItem "My Reflected Death (May 9, 2012)"                              "MyReflectedDeath666"
call :addItem "What Is Love? (July 12, 2012)"                                 "WhatIsLove999"
call :addItem "Ivory Heart (December 21, 2012)"                               "IvoryHeart666"
call :addItem "Living Neverland (January 26, 2013)"                           "LivingNeverland666"
call :addItem "Song of Wend (April 23, 2013)"                                 "SongOfWend"
call :addItem "1984 (June 27, 2013)"                                          "1984666"
call :addItem "Independence Year 4 Kidz (July 15, 2013)"                      "IndependenceYear4Kidz"
call :addItem "Dear Ashley (February 14, 2014)"                               "DearAshley"
call :addItem "My Symposium (July 27, 2015)"                                  "MySymposium666"
call :addItem "Cross of Man (July 28, 2015)"                                  "CrossOfMan"
call :addItem "My Dating Profile (August 7, 2015)"                            "MyDatingProfile"
call :addItem "Project Notebook (September 19, 2015)"                         "ProjectNotebook"
call :addItem "Time Masheen (September 25, 2015)"                             "TimeMasheen"
call :addItem "Yo Contract (October 15, 2015)"                                "YoContract"
call :addItem "State of Emergency (November 6, 2015)"                         "StateOfEmergency666"
call :addItem "World War III (November 12, 2015)"                             "WorldWarIII666"
call :addItem "The Televised Revelation (November 16, 2015)"                  "TheTelevisedRevelation"
call :addItem "Ivory Heart II (November 19, 2015)"                            "IvoryHeartII"
call :addItem "Ivory Heart III (December 6, 2015)"                            "IvoryHeartIII"
call :addItem "Retribution (December 25, 2015)"                               "Retribution-DT"
call :addItem "Marionettes (March 3, 2016)"                                   "Marionettes666"
call :addItem "Technomadology (April 2, 2018)"                                "Technomadology"
call :addItem "Our Rapture (April 21, 2018)"                                  "OurRapture"
call :addItem "War Games (June 6, 2018)"                                      "WarGames666"
call :addItem "The Antichrist (June 9, 2018)"                                 "TheAntichrist666"
call :addItem "Ave Maria (June 22, 2018)"                                     "AveMaria666"
call :addItem "Rebirthing (July 29, 2018)"                                    "Rebirthing999"
call :addItem "Inas Shawket (April 25, 2020)"                                 "inas-shawket"
call :addItem "My Girls (November 20, 2020)"                                  "my-girls"
call :addItem "Matchmaker (December 2, 2020)"                                 "matchmakerU"
call :addItem "Phoenix Rising (December 3, 2020)"                             "phoenix-rising"
call :addItem "Wendell Charles NeSmith (January 30, 2021)"                    "wendell-charles-nesmith"
call :addItem "A Star Is Born (February 18, 2021)"                            "a-star-is-born-2021"
call :addItem "Open Source University (April 2, 2021)"                        "open-source-university"
call :addItem "Jaybee (November 22, 2021)"                                    "jaybee"
call :addItem "I Love God (March 17, 2022)"                                   "i-love-god"
call :addItem "Closure (June 14, 2022)"                                       "closure2022"
call :addItem "REPUBLICKA (2023 - current)"                                   "REPUBLICKA"
call :addItem "Meet David and Goliath (2025)"                                 "MEET-DAVID-AND-GOLIATH"
call :addItem "Atheden Podcasts (2025 - current)"                             "atheden-podcasts"

:: =========================================================
::  MENU
:: =========================================================
:menu
cls
echo OPEN SOURCE HEART TV — Archive Mirror
echo.
echo Downloads root: %DESTROOT%
echo Oldest = 1 at the TOP. Newest = %COUNT% at the BOTTOM.
echo.
echo Select an item to mirror:
echo.

for /L %%N in (1,1,%COUNT%) do (
  call echo  %%N^) !LABEL_%%N!
)

echo.
set /p CHOICE=Enter number (1-%COUNT%) or Q to quit: 

if /I "%CHOICE%"=="Q" goto :eof

for /f "delims=0123456789" %%A in ("%CHOICE%") do (
  echo Invalid choice.
  pause
  goto menu
)

if %CHOICE% LSS 1 (
  echo Invalid choice.
  pause
  goto menu
)

if %CHOICE% GTR %COUNT% (
  echo Invalid choice.
  pause
  goto menu
)

set "IA_ID=!ID_%CHOICE%!"
set "IA_LABEL=!LABEL_%CHOICE%!"
echo.
echo Mirroring: !IA_LABEL!
echo Archive ID: %IA_ID%
echo.

set "OUTROOT=%DESTROOT%\%IA_ID%"
if not exist "%OUTROOT%" mkdir "%OUTROOT%"

set "URL=https://archive.org/download/%IA_ID%/"

:: =========================================================
::  WRITE POWERSHELL MIRROR SCRIPT
:: =========================================================
set "TMPPS=%OUTROOT%\_osht_mirror_tmp.ps1"

> "%TMPPS%" echo param([string]$Url,[string]$OutDir)
>>"%TMPPS%" echo $wc = New-Object System.Net.WebClient
>>"%TMPPS%" echo $indexHtml = $wc.DownloadString($Url)
>>"%TMPPS%" echo $pattern = 'href="([^"]+)"'
>>"%TMPPS%" echo $matches_ = [regex]::Matches($indexHtml, $pattern)
>>"%TMPPS%" echo $links = $matches_ ^| ForEach-Object { $_.Groups[1].Value }
>>"%TMPPS%" echo $downloaded = 0
>>"%TMPPS%" echo $skipped    = 0
>>"%TMPPS%" echo $redownloaded = 0
>>"%TMPPS%" echo $filtered   = 0
>>"%TMPPS%" echo foreach ($l in $links) {
>>"%TMPPS%" echo   if ($l.StartsWith("/") -or $l.StartsWith("?") -or $l.StartsWith("http") -or $l -eq "/" -or $l.EndsWith("/")) { continue }
>>"%TMPPS%" echo   $ext = [System.IO.Path]::GetExtension($l).ToLower()
>>"%TMPPS%" echo   if ($ext -ne '.mp4') { $filtered++; continue }
>>"%TMPPS%" echo   if ($l -like '*.ia.mp4') { $filtered++; continue }
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

echo Mirroring MP4 files from Internet Archive...
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
goto :menu

:: =========================================================
::  SUBROUTINE: REGISTER ITEM
:: =========================================================
:addItem
set /a COUNT+=1
set "LABEL_%COUNT%=%~1"
set "ID_%COUNT%=%~2"
goto :eof