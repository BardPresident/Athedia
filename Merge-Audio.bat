@echo off
setlocal enabledelayedexpansion

set "outputfile=Audiobook-Merged.mp3"
set "listfile=%temp%\mp3list_%random%.txt"
if exist "%listfile%" del "%listfile%"

for /f "delims=" %%f in ('dir /b /on /a-d "*.mp3"') do (
  if /i not "%%f"=="%outputfile%" (
    echo file '%%~ff'>>"%listfile%"
  )
)

echo Merging mp3 files in order:
type "%listfile%"
echo.

ffmpeg -f concat -safe 0 -i "%listfile%" -c:a libmp3lame -b:a 192k "%outputfile%"

del "%listfile%"

echo.
echo Done. Merged audiobook saved as "%outputfile%"
pause