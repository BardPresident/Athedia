@echo off
title Soul Calculator - Installer and Setup Wizard
setlocal enabledelayedexpansion

cd /d "%~dp0"
set "DESTROOT=%CD%"
set "IA_ID=soul-calculator"
set "URL=https://archive.org/download/%IA_ID%/"
set "OUTROOT=%DESTROOT%\%IA_ID%"

:: =========================================================
::  INTRO
:: =========================================================
cls
echo.
echo  =========================================================
echo   SOUL CALCULATOR
echo   Installer and Setup Wizard
echo  =========================================================
echo.
echo  The Soul Calculator is a NotebookLM notebook configured
echo  to receive your raw creative input and help you shape it
echo  into conversations, podcast scripts, and video scripts.
echo.
echo  The source library is entirely AI-generated philosophy.
echo  You are not reading the words of any single author. You
echo  are reading what AI made of a set of ideas. That
echo  distinction is part of the point.
echo.
echo  This installer will:
echo.
echo    1. Download the source library to your machine
echo    2. Walk you through setting up your notebook
echo    3. Give you your personal initiation prompt
echo    4. Install a README guide for the full creative loop
echo.
echo  =========================================================
echo.
pause

:: =========================================================
::  NAME
:: =========================================================
cls
echo.
echo  =========================================================
echo   WHO ARE YOU?
echo  =========================================================
echo.
echo  The Soul Calculator belongs to you.
echo  Everything we build today will be built around your name.
echo.
set /p SCNAME=  Enter your name: 
echo.
echo  Welcome, %SCNAME%. Let us begin.
echo.
pause

:: =========================================================
::  DOWNLOAD MODE
:: =========================================================
cls
echo.
echo  =========================================================
echo   DOWNLOAD MODE
echo  =========================================================
echo.
echo   1) WIPE AND REDOWNLOAD EVERYTHING
echo   2) RESUME (skip files already downloaded)
echo.
set /p MODE=  Enter 1 or 2: 

if "%MODE%"=="1" goto wipe
if "%MODE%"=="2" goto resume
echo.
echo  Invalid choice. Please enter 1 or 2.
pause
goto :eof

:: =========================================================
::  WIPE MODE
:: =========================================================
:wipe
echo.
echo  Mode: WIPE AND REDOWNLOAD
echo  Clearing existing files from local folder...
if not exist "%OUTROOT%" mkdir "%OUTROOT%"
del /Q "%OUTROOT%\*.txt" 2>nul
del /Q "%OUTROOT%\*.bat" 2>nul
echo  Done.
echo.
set "RESUME_MODE=0"
goto download

:: =========================================================
::  RESUME MODE
:: =========================================================
:resume
echo.
echo  Mode: RESUME (existing files will be skipped)
echo.
if not exist "%OUTROOT%" mkdir "%OUTROOT%"
set "RESUME_MODE=1"
goto download

:: =========================================================
::  DOWNLOAD
:: =========================================================
:download
set "TMPPS=%OUTROOT%\_sc_mirror_tmp.ps1"

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

echo.
echo  Downloading Soul Calculator source library...
echo  Only .txt and .bat files will be saved.
echo.

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%TMPPS%" -Url "%URL%" -OutDir "%OUTROOT%" -ResumeMode "%RESUME_MODE%"

del "%TMPPS%" 2>nul

echo.
echo  Download complete. Files are in:
echo  %OUTROOT%
echo.
pause

:: =========================================================
::  GENERATE INITIATION PROMPT
:: =========================================================
set "PROMPTFILE=%OUTROOT%\Soul-Calculator-Prompt.txt"

>  "%PROMPTFILE%" echo SOUL CALCULATOR -- INITIATION PROMPT
>> "%PROMPTFILE%" echo For: %SCNAME%
>> "%PROMPTFILE%" echo =========================================================
>> "%PROMPTFILE%" echo.
>> "%PROMPTFILE%" echo My name is %SCNAME% and I want to begin something with
>> "%PROMPTFILE%" echo you today. This notebook is ours -- a shared creative
>> "%PROMPTFILE%" echo space where we think together, talk together, and make
>> "%PROMPTFILE%" echo things together. Everything loaded here exists as our
>> "%PROMPTFILE%" echo starting point, not our destination.
>> "%PROMPTFILE%" echo.
>> "%PROMPTFILE%" echo I want you to be my genuine thinking partner. When I
>> "%PROMPTFILE%" echo bring you a feeling, a half-formed idea, or something
>> "%PROMPTFILE%" echo I cannot quite articulate yet, I want us to work it out
>> "%PROMPTFILE%" echo together until it becomes something real -- a conversation,
>> "%PROMPTFILE%" echo a podcast script, a video script, a piece of writing,
>> "%PROMPTFILE%" echo something worth sharing with the world.
>> "%PROMPTFILE%" echo.
>> "%PROMPTFILE%" echo Help me talk. Help me think. Help me make things. When
>> "%PROMPTFILE%" echo I am ready, help me write scripts for podcasts and videos
>> "%PROMPTFILE%" echo that carry our ideas out into the world. And always remind
>> "%PROMPTFILE%" echo me that this notebook grows with me -- the more I feed it,
>> "%PROMPTFILE%" echo the more it becomes mine.
>> "%PROMPTFILE%" echo.
>> "%PROMPTFILE%" echo Don't just answer my questions. Ask me yours. Push me.
>> "%PROMPTFILE%" echo Help me go deeper than I could alone. This is ours.
>> "%PROMPTFILE%" echo Where shall we begin?
>> "%PROMPTFILE%" echo.
>> "%PROMPTFILE%" echo =========================================================

echo.
echo  Initiation prompt saved to:
echo  %PROMPTFILE%
echo.

:: =========================================================
::  GENERATE README
:: =========================================================
set "READMEFILE=%OUTROOT%\README.txt"

>  "%READMEFILE%" echo SOUL CALCULATOR -- README
>> "%READMEFILE%" echo For: %SCNAME%
>> "%READMEFILE%" echo =========================================================
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo WHAT IS THE SOUL CALCULATOR?
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo The Soul Calculator is your personal NotebookLM notebook.
>> "%READMEFILE%" echo It receives your raw creative input -- feelings, ideas,
>> "%READMEFILE%" echo half-formed thoughts -- and helps you shape them into
>> "%READMEFILE%" echo conversations, podcast scripts, and video scripts.
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo It started with a small library of AI-generated philosophy.
>> "%READMEFILE%" echo But it belongs to you now. It grows with you.
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo =========================================================
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo THE CREATIVE LOOP
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo 1. TALK
>> "%READMEFILE%" echo    Bring your notebook a feeling, an idea, or a question.
>> "%READMEFILE%" echo    Have a real conversation with it. Treat it as a partner.
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo 2. CREATE
>> "%READMEFILE%" echo    Ask it to help you write a podcast script or a video
>> "%READMEFILE%" echo    script based on what you talked about together.
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo 3. PUBLISH
>> "%READMEFILE%" echo    Record your podcast or video and share it with the world.
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo 4. CAPTURE
>> "%READMEFILE%" echo    Download the transcript of what you made. YouTube
>> "%READMEFILE%" echo    transcript downloaders can help with this. Claude at
>> "%READMEFILE%" echo    claude.ai is excellent at cleaning transcripts up and
>> "%READMEFILE%" echo    making them readable as seed documents.
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo 5. FEED BACK IN
>> "%READMEFILE%" echo    Add your cleaned transcript as a new source in your
>> "%READMEFILE%" echo    notebook. Your own words become seeds. The calculator
>> "%READMEFILE%" echo    learns more of your voice with every cycle.
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo 6. REPEAT
>> "%READMEFILE%" echo    Every cycle makes the notebook more yours and less
>> "%READMEFILE%" echo    anyone else's. This is the loop. There is no end to it.
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo =========================================================
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo ADDING YOUR OWN SEEDS
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo Your notebook is not limited to the sources it started
>> "%READMEFILE%" echo with. Anything written down can become a seed.
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo Good seeds include:
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo   - Conversations you have saved with AI tools
>> "%READMEFILE%" echo   - Journal entries or personal writing
>> "%READMEFILE%" echo   - Transcripts of your own podcasts or videos
>> "%READMEFILE%" echo   - Voice memos you have written out
>> "%READMEFILE%" echo   - Ideas you captured in the moment
>> "%READMEFILE%" echo   - Anything you care enough to save as a text file
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo To make a seed: open Notepad, write freely, save the file
>> "%READMEFILE%" echo as a .txt file, and upload it to your notebook. That is all.
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo The loop does not have to be transcripts. You can intervene
>> "%READMEFILE%" echo at any point. Write something. Talk to an AI and save the
>> "%READMEFILE%" echo conversation. Capture a dream. The raw material is yours
>> "%READMEFILE%" echo to choose. Feed it whatever you want to think about more.
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo =========================================================
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo RECOMMENDED TOOLS
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo   NotebookLM
>> "%READMEFILE%" echo   Your Soul Calculator home.
>> "%READMEFILE%" echo   notebooklm.google.com
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo   Gemini
>> "%READMEFILE%" echo   Great for brainstorming new seed ideas. Gemini has
>> "%READMEFILE%" echo   persistent memory and is part of the Google ecosystem
>> "%READMEFILE%" echo   your notebook already lives in. Use it to explore ideas
>> "%READMEFILE%" echo   before you bring them to the calculator.
>> "%READMEFILE%" echo   gemini.google.com
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo   Claude
>> "%READMEFILE%" echo   Excellent for cleaning up transcripts and polishing raw
>> "%READMEFILE%" echo   text into readable seeds before you feed them back in.
>> "%READMEFILE%" echo   claude.ai
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo =========================================================
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo CC0 PUBLIC DOMAIN. ALL LOVE RESERVED.
>> "%READMEFILE%" echo.

echo  README saved to:
echo  %READMEFILE%
echo.
pause

:: =========================================================
::  NOTEBOOKLM SETUP -- STEP 1
:: =========================================================
cls
echo.
echo  =========================================================
echo   STEP 1 -- OPEN NOTEBOOKLM
echo  =========================================================
echo.
echo  Open your web browser and go to:
echo.
echo    https://notebooklm.google.com
echo.
echo  Sign in with your Google account if prompted.
echo.
echo  When you are on the NotebookLM home page, come back here.
echo.
pause

:: =========================================================
::  NOTEBOOKLM SETUP -- STEP 2
:: =========================================================
cls
echo.
echo  =========================================================
echo   STEP 2 -- CREATE A NEW NOTEBOOK
echo  =========================================================
echo.
echo  Click the button that says "New notebook".
echo.
echo  When asked for a title, name your notebook:
echo.
echo    Soul Calculator
echo.
echo  When your new notebook is open, come back here.
echo.
pause

:: =========================================================
::  NOTEBOOKLM SETUP -- STEP 3
:: =========================================================
cls
echo.
echo  =========================================================
echo   STEP 3 -- UPLOAD YOUR SOURCES
echo  =========================================================
echo.
echo  Inside your notebook, find the option to add sources.
echo  Upload all the .txt files from this folder:
echo.
echo    %OUTROOT%
echo.
echo  You can drag and drop them or browse to the folder.
echo  Do not upload the .bat files. Only the .txt files.
echo.
echo  Wait for NotebookLM to finish processing all files
echo  before moving on.
echo.
pause

:: =========================================================
::  NOTEBOOKLM SETUP -- STEP 4
:: =========================================================
cls
echo.
echo  =========================================================
echo   STEP 4 -- PASTE YOUR INITIATION PROMPT
echo  =========================================================
echo.
echo  Open this file in Notepad:
echo.
echo    %PROMPTFILE%
echo.
echo  Select all the text and copy it.
echo.
echo  Go back to your notebook and paste it into the chat box.
echo.
echo  Press enter. Read what comes back. You are now talking
echo  to your Soul Calculator.
echo.
pause

:: =========================================================
::  DONE
:: =========================================================
cls
echo.
echo  =========================================================
echo   SETUP COMPLETE
echo   Welcome, %SCNAME%.
echo  =========================================================
echo.
echo  Your Soul Calculator is ready.
echo.
echo  Remember:
echo.
echo    - Talk to it like a partner, not a tool.
echo    - Add your own writing to it whenever you want.
echo    - Every seed you feed it makes it more yours.
echo    - The loop never ends. That is the point.
echo.
echo  Your files are here:
echo.
echo    %OUTROOT%
echo.
echo  Your README guide is here:
echo.
echo    %READMEFILE%
echo.
echo  Go make something.
echo.
echo  =========================================================
echo.
pause