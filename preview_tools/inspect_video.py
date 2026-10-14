from __future__ import annotations

import argparse
import math
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / ".deps"))

import av  # type: ignore  # noqa: E402
from PIL import Image, ImageDraw, ImageFont  # noqa: E402


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("video", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--samples", type=int, default=12)
    parser.add_argument("--start", type=float, default=0.0)
    parser.add_argument("--end", type=float)
    args = parser.parse_args()

    with av.open(str(args.video)) as container:
        stream = container.streams.video[0]
        duration = float(stream.duration * stream.time_base) if stream.duration else float(container.duration / av.time_base)
        fps = float(stream.average_rate) if stream.average_rate else 0.0
        metadata = {
            "duration": duration,
            "fps": fps,
            "width": stream.width,
            "height": stream.height,
            "frames": stream.frames,
        }

        start = max(0.0, args.start)
        end = min(duration, args.end if args.end is not None else duration)
        sample_times = [start + (end - start) * i / max(args.samples - 1, 1) for i in range(args.samples)]
        frames: list[tuple[float, Image.Image]] = []
        for time_s in sample_times:
            container.seek(int(time_s * av.time_base), backward=True, any_frame=False)
            frame = next(container.decode(stream))
            image = frame.to_image()
            image.thumbnail((420, 300), Image.Resampling.LANCZOS)
            frames.append((time_s, image.copy()))

    cols = 3
    rows = math.ceil(len(frames) / cols)
    cell_w, cell_h = 440, 345
    sheet = Image.new("RGB", (cell_w * cols, cell_h * rows), "#111318")
    draw = ImageDraw.Draw(sheet)
    font = ImageFont.load_default(size=20)
    for index, (time_s, image) in enumerate(frames):
        x = (index % cols) * cell_w
        y = (index // cols) * cell_h
        px = x + (cell_w - image.width) // 2
        py = y + 8
        sheet.paste(image, (px, py))
        draw.text((x + 12, y + 312), f"{time_s:6.2f} s", fill="#F2EDE4", font=font)

    args.output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(args.output, quality=92)
    print(metadata)
    print(args.output)


if __name__ == "__main__":
    main()
