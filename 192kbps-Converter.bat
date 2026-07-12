@echo off
mkdir "converted" 2>nul

for %%f in (*.mp4) do (
  echo Processing "%%f"...
  ffmpeg -i "%%f" ^
    -vn -c:a libmp3lame -b:a 192k ^
    "converted\%%~nf.mp3"
)

echo.
echo Done. Converted files are in the "converted" folder.
pause