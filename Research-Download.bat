@echo off
title Research - Installer and Setup Wizard
setlocal enabledelayedexpansion

cd /d "%~dp0"
set "DESTROOT=%CD%"
set "IA_ID=research-999"
set "URL=https://archive.org/download/%IA_ID%/"
set "OUTROOT=%DESTROOT%\%IA_ID%"

:: =========================================================
::  INTRO
:: =========================================================
cls
echo.
echo  =========================================================
echo   RESEARCH
echo   Installer and Setup Wizard
echo  =========================================================
echo.
echo  Research is a NotebookLM notebook configured to run
echo  top-down epistemology. Rather than building up from
echo  data toward conclusions, it starts from what you can
echo  observe right now and traces the pattern backward --
echo  stripping away noise until the causal signal holds.
echo.
echo  The source library is Book 186: Theogony by
echo  Wendell Charles NeSmith, released CC0 into the public
echo  domain. Load it and the notebook is ready to run.
echo.
echo  This installer will:
echo.
echo    1. Download the source library to your machine
echo    2. Walk you through setting up your notebook
echo    3. Give you your personal initiation prompt
echo    4. Install a README guide for the full workflow
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
echo  Research belongs to you.
echo  Everything we build today will be built around your name.
echo.
set /p SCNAME=  Enter your name: 
echo.
echo  Welcome, %SCNAME%. Let us begin.
echo.
pause

:: =========================================================
::  DOWNLOAD
:: =========================================================
cls
echo.
echo  Clearing any existing files and downloading fresh...
echo.
if not exist "%OUTROOT%" mkdir "%OUTROOT%"
del /Q "%OUTROOT%\*.txt" 2>nul
del /Q "%OUTROOT%\*.bat" 2>nul

set "TMPPS=%OUTROOT%\_res_mirror_tmp.ps1"

> "%TMPPS%" echo param([string]$Url,[string]$OutDir)
>>"%TMPPS%" echo $wc = New-Object System.Net.WebClient
>>"%TMPPS%" echo $allowed = @('.txt','.bat')
>>"%TMPPS%" echo $indexHtml = $wc.DownloadString($Url)
>>"%TMPPS%" echo $pattern = 'href="([^"]+)"'
>>"%TMPPS%" echo $matches_ = [regex]::Matches($indexHtml, $pattern)
>>"%TMPPS%" echo $links = $matches_ ^| ForEach-Object { $_.Groups[1].Value }
>>"%TMPPS%" echo $downloaded = 0
>>"%TMPPS%" echo $filtered   = 0
>>"%TMPPS%" echo foreach ($l in $links) {
>>"%TMPPS%" echo   if ($l.StartsWith("/") -or $l.StartsWith("?") -or $l.StartsWith("http") -or $l -eq "/" -or $l.EndsWith("/")) { continue }
>>"%TMPPS%" echo   $ext = [System.IO.Path]::GetExtension($l).ToLower()
>>"%TMPPS%" echo   if ($allowed -notcontains $ext) { $filtered++; continue }
>>"%TMPPS%" echo   $decoded = [System.Uri]::UnescapeDataString($l)
>>"%TMPPS%" echo   $clean   = $decoded -replace '[\\/:*?"<>|]',''
>>"%TMPPS%" echo   $of      = Join-Path $OutDir $clean
>>"%TMPPS%" echo   $fu = ($Url.TrimEnd('/') + '/' + $l)
>>"%TMPPS%" echo   Write-Host "GET  $clean"
>>"%TMPPS%" echo   try {
>>"%TMPPS%" echo     $wc.DownloadFile($fu, $of)
>>"%TMPPS%" echo     $downloaded++
>>"%TMPPS%" echo   } catch {
>>"%TMPPS%" echo     Write-Host "FAIL $fu : $_"
>>"%TMPPS%" echo   }
>>"%TMPPS%" echo }
>>"%TMPPS%" echo Write-Host "Done. Downloaded: $downloaded  Filtered: $filtered"

echo  Downloading Research source library...
echo  Only .txt and .bat files will be saved.
echo.

powershell -NoLogo -NoProfile -ExecutionPolicy Bypass -File "%TMPPS%" -Url "%URL%" -OutDir "%OUTROOT%"

del "%TMPPS%" 2>nul

echo.
echo  Download complete. Files are in:
echo  %OUTROOT%
echo.
pause

:: =========================================================
::  GENERATE INITIATION PROMPT
:: =========================================================
set "PROMPTFILE=%OUTROOT%\Research-Prompt.txt"

>  "%PROMPTFILE%" echo RESEARCH -- INITIATION PROMPT
>> "%PROMPTFILE%" echo For: %SCNAME%
>> "%PROMPTFILE%" echo =========================================================
>> "%PROMPTFILE%" echo.
>> "%PROMPTFILE%" echo My name is %SCNAME% and I am opening this notebook
>> "%PROMPTFILE%" echo as a working laboratory. Everything loaded here is our
>> "%PROMPTFILE%" echo starting framework -- not a set of conclusions to defend,
>> "%PROMPTFILE%" echo but a set of instruments to use.
>> "%PROMPTFILE%" echo.
>> "%PROMPTFILE%" echo I want you to be my top-down research partner. When I
>> "%PROMPTFILE%" echo bring you a phenomenon, an anomaly, an unresolved question,
>> "%PROMPTFILE%" echo or a body of data, I want us to approach it the same way:
>> "%PROMPTFILE%" echo start from what we can observe right now, ask what
>> "%PROMPTFILE%" echo underlying pattern must be true for this to be the result,
>> "%PROMPTFILE%" echo and trace backward through the possible histories until
>> "%PROMPTFILE%" echo only the coherent ones remain.
>> "%PROMPTFILE%" echo.
>> "%PROMPTFILE%" echo Do not build up from the bottom if the bottom is noise.
>> "%PROMPTFILE%" echo Start at the top and work down. Strip the polysemantic
>> "%PROMPTFILE%" echo surface away and find the causal signal underneath.
>> "%PROMPTFILE%" echo When the uncertainty is too high, say so -- abstain
>> "%PROMPTFILE%" echo rather than speculate. Epistemic honesty is the
>> "%PROMPTFILE%" echo instrument, not a failure of it.
>> "%PROMPTFILE%" echo.
>> "%PROMPTFILE%" echo Push the calculation further than I would take it alone.
>> "%PROMPTFILE%" echo Show me what the framework finds when I am not looking
>> "%PROMPTFILE%" echo hard enough. This notebook sharpens with every question.
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

>  "%READMEFILE%" echo RESEARCH -- README
>> "%READMEFILE%" echo For: %SCNAME%
>> "%READMEFILE%" echo =========================================================
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo WHAT IS RESEARCH?
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo Research is your personal NotebookLM notebook for
>> "%READMEFILE%" echo top-down epistemology. Where conventional science
>> "%READMEFILE%" echo builds up from data toward conclusions, Research
>> "%READMEFILE%" echo starts from the present observation and traces the
>> "%READMEFILE%" echo patterns backward -- stripping away noise until
>> "%READMEFILE%" echo the causal signal underneath is isolated and the
>> "%READMEFILE%" echo structure holds.
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo It started with a source library of philosophy and
>> "%READMEFILE%" echo epistemological framework. But it belongs to you now.
>> "%READMEFILE%" echo It sharpens with every question you run through it.
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo =========================================================
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo THE TWO OPERATIONS
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo 1. TOP-DOWN PATTERN TRACING
>> "%READMEFILE%" echo    Begin with the present observation. Ask what pattern
>> "%READMEFILE%" echo    must be true for this to be the result. Trace backward
>> "%READMEFILE%" echo    through the possible histories until only the coherent
>> "%READMEFILE%" echo    ones remain. Do not wait for the bottom-up data to
>> "%READMEFILE%" echo    solidify. Start at the top and work down.
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo 2. CAUSAL SIGNAL ISOLATION
>> "%READMEFILE%" echo    Strip polysemantic noise from the data. Identify the
>> "%READMEFILE%" echo    genuine causal structure underneath. Fluid emotional
>> "%READMEFILE%" echo    intent crystallizes into logical infrastructure --
>> "%READMEFILE%" echo    find where the freeze happened and what drove it.
>> "%READMEFILE%" echo    When uncertainty is too high, abstain. Do not speculate.
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo =========================================================
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo WHAT TO FEED IT
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo Good inputs include:
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo   - Anomalous observations or data that existing
>> "%READMEFILE%" echo     frameworks fail to explain
>> "%READMEFILE%" echo   - Existing theories or models you want tested
>> "%READMEFILE%" echo     against the top-down framework
>> "%READMEFILE%" echo   - Source code or system architecture to
>> "%READMEFILE%" echo     reverse-engineer the underlying logic
>> "%READMEFILE%" echo   - Historical texts or research notes you want
>> "%READMEFILE%" echo     re-read from the top down
>> "%READMEFILE%" echo   - Your own working notes on a phenomenon or
>> "%READMEFILE%" echo     hypothesis in development
>> "%READMEFILE%" echo   - Any complex system where the causal structure
>> "%READMEFILE%" echo     is entangled and needs isolating
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo To make an input: save your material as a .txt file
>> "%READMEFILE%" echo and upload it to your notebook as a new source.
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo =========================================================
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo RECOMMENDED TOOLS
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo   NotebookLM
>> "%READMEFILE%" echo   Your Research laboratory.
>> "%READMEFILE%" echo   notebooklm.google.com
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo   Gemini
>> "%READMEFILE%" echo   Good for articulating your research question
>> "%READMEFILE%" echo   clearly before you bring it to the notebook.
>> "%READMEFILE%" echo   gemini.google.com
>> "%READMEFILE%" echo.
>> "%READMEFILE%" echo   Claude
>> "%READMEFILE%" echo   Excellent for cleaning up raw text before feeding
>> "%READMEFILE%" echo   it in as a source document.
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
echo    Research
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
echo  Press enter. Read what comes back. Research
echo  is now open and calibrated to you.
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
echo  Research is ready.
echo.
echo  Remember:
echo.
echo    - Start at the top, not the bottom.
echo    - Feed it phenomena, not just questions.
echo    - When the uncertainty is too high, abstain.
echo    - Every source you add sharpens the lens.
echo    - The calculation is a tool, not a verdict.
echo.
echo  Your files are here:
echo.
echo    %OUTROOT%
echo.
echo  Your README guide is here:
echo.
echo    %READMEFILE%
echo.
echo  Run the calculation.
echo.
echo  =========================================================
echo.
pause