@echo off
mkdir "converted" 2>nul

for %%f in (*.mp4) do (
  echo Processing "%%f"...
  ffmpeg -i "%%f" ^
    -vf "scale=1280:720:force_original_aspect_ratio=decrease,pad=1280:720:(ow-iw)/2:(oh-ih)/2:black" ^
    -c:v libx264 -preset veryfast -crf 24 ^
    -c:a aac -b:a 128k ^
    "converted\%%~nf.mp4"
)

echo.
echo Done. Converted files are in the "converted" folder.
pause
