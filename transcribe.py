import os
import re
from faster_whisper import WhisperModel

EXTENSIONS = ('.mp4', '.mp3')
MODEL_NAME = "large-v3-turbo"
DEVICE = "cuda"
COMPUTE_TYPE = "float16"

# Load Model
print(f"Loading Whisper model ({MODEL_NAME}) on {DEVICE}...")
model = WhisperModel(MODEL_NAME, device=DEVICE, compute_type=COMPUTE_TYPE)
print("Model ready.\n")

def format_into_paragraphs(segments, pause_threshold_sec=1.5, max_sentences=4):
    """
    Groups fragments into natural paragraphs based on speaker pauses and punctuation.
    """
    paragraphs = []
    current_sentences = []
    last_end = 0.0

    for segment in segments:
        text = segment.text.strip()
        if not text:
            continue

        # If there's a pause longer than threshold between segments, start a new paragraph
        pause_duration = segment.start - last_end
        if pause_duration >= pause_threshold_sec and current_sentences:
            paragraphs.append(" ".join(current_sentences))
            current_sentences = []

        current_sentences.append(text)
        last_end = segment.end

        # Also cap paragraph length so it doesn't run on forever
        joined = " ".join(current_sentences)
        sentence_end_count = len(re.findall(r'[.!?](?:\s|$)', joined))
        if sentence_end_count >= max_sentences:
            paragraphs.append(joined)
            current_sentences = []

    if current_sentences:
        paragraphs.append(" ".join(current_sentences))

    # Standardize spacing and return clean text with blank lines between paragraphs
    return "\n\n".join(p.strip() for p in paragraphs if p.strip())

files = [f for f in os.listdir('.') if f.lower().endswith(EXTENSIONS)]

for filename in files:
    txt_path = os.path.splitext(filename)[0] + ".txt"
    if os.path.exists(txt_path):
        print(f"[SKIPPING] '{txt_path}' already exists.")
        continue

    print(f"[PROCESSING] '{filename}' -> '{txt_path}'")
    
    # Transcription with VAD and condition controls for consistent output
    segments, _ = model.transcribe(
        filename,
        vad_filter=True,
        vad_parameters=dict(min_silence_duration_ms=500),
        condition_on_previous_text=False,
        beam_size=5
    )

    clean_content = format_into_paragraphs(segments)
    
    with open(txt_path, 'w', encoding='utf-8') as f:
        f.write(clean_content + "\n")
            
    print(f"[SUCCESS] Saved to '{txt_path}'\n")

print("All files processed.")