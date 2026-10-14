from __future__ import annotations

import argparse
import bisect
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / ".deps"))

import av  # type: ignore  # noqa: E402
from PIL import Image, ImageDraw, ImageFont  # noqa: E402


FPS = 30
WIDTH = 720
HEIGHT = 1280
ACCENT = "#FF5A1F"
IVORY = "#F2EDE4"
INK = "#0B0B0E"
GREEN = "#123F2D"


def load_font(size: int, bold: bool = False) -> ImageFont.FreeTypeFont:
    candidates = [
        Path(r"C:\Windows\Fonts\msjhbd.ttc" if bold else r"C:\Windows\Fonts\msjh.ttc"),
        Path(r"C:\Windows\Fonts\NotoSansTC-VF.ttf"),
        Path(r"C:\Windows\Fonts\arialbd.ttf" if bold else r"C:\Windows\Fonts\arial.ttf"),
    ]
    for path in candidates:
        if path.exists():
            return ImageFont.truetype(str(path), size=size)
    return ImageFont.load_default(size=size)


FONT_28 = load_font(28)
FONT_32_B = load_font(32, bold=True)
FONT_42_B = load_font(42, bold=True)
FONT_54_B = load_font(54, bold=True)


def rounded_label(draw: ImageDraw.ImageDraw, xy: tuple[int, int, int, int], text: str, *, fill: str, font: ImageFont.ImageFont) -> None:
    draw.rounded_rectangle(xy, radius=22, fill=fill)
    box = draw.textbbox((0, 0), text, font=font)
    tw = box[2] - box[0]
    th = box[3] - box[1]
    x1, y1, x2, y2 = xy
    draw.text(((x1 + x2 - tw) / 2, (y1 + y2 - th) / 2 - 3), text, font=font, fill=IVORY)


def overlay(frame: Image.Image, timeline_s: float, section: str, phase: str, subtitle: str) -> Image.Image:
    base = frame.convert("RGBA")
    layer = Image.new("RGBA", base.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    draw.rounded_rectangle((28, 30, 692, 150), radius=30, fill=(11, 11, 14, 218))
    draw.text((58, 48), "正手殺球｜30 秒動作試作", font=FONT_32_B, fill=IVORY)
    draw.rectangle((58, 112, 662, 120), fill=(73, 75, 78, 220))
    draw.rectangle((58, 112, 58 + int(604 * min(timeline_s / 30.0, 1.0)), 120), fill=ACCENT)

    rounded_label(draw, (32, 176, 238, 235), section, fill=GREEN, font=FONT_28)
    if phase:
        rounded_label(draw, (458, 176, 688, 235), phase, fill=ACCENT, font=FONT_28)

    draw.rounded_rectangle((30, 1065, 690, 1230), radius=30, fill=(11, 11, 14, 220))
    draw.text((58, 1092), subtitle, font=FONT_42_B, fill=IVORY)
    draw.text((58, 1152), "重點：側身架拍 → 蹬地轉體 → 前上方擊球", font=FONT_28, fill=(242, 237, 228, 225))

    return Image.alpha_composite(base, layer).convert("RGB")


def load_source_frames(video: Path, start: float, end: float) -> tuple[list[float], list[Image.Image]]:
    times: list[float] = []
    images: list[Image.Image] = []
    with av.open(str(video)) as container:
        stream = container.streams.video[0]
        container.seek(int(max(0.0, start - 2.0) * av.time_base), backward=True, any_frame=False)
        for frame in container.decode(stream):
            if frame.pts is None:
                continue
            time_s = float(frame.pts * frame.time_base)
            if time_s < start:
                continue
            if time_s > end:
                break
            image = frame.to_image().convert("RGB")
            if image.size != (WIDTH, HEIGHT):
                image = image.resize((WIDTH, HEIGHT), Image.Resampling.LANCZOS)
            times.append(time_s)
            images.append(image)
    if not images:
        raise RuntimeError("指定區間找不到任何影格")
    return times, images


def nearest(times: list[float], images: list[Image.Image], source_time: float) -> Image.Image:
    index = bisect.bisect_left(times, source_time)
    if index >= len(times):
        index = len(times) - 1
    elif index > 0 and abs(times[index - 1] - source_time) < abs(times[index] - source_time):
        index -= 1
    return images[index]


def map_timeline(t: float) -> tuple[float, str, str, str]:
    if t < 2.0:
        return 157.55, "動作預覽", "", "先看完整節奏"
    if t < 8.0:
        return 155.30 + (t - 2.0), "正常速度", "完整動作", "準備、擊球、回位"
    if t < 17.0:
        return 157.00 + (t - 8.0) / 3.0, "慢動作 0.33×", "擊球段", "注意擊球點在身體前上方"
    if t < 24.0:
        local = t - 17.0
        source_time = 157.20 + local / 3.0
        if source_time < 158.10:
            phase, subtitle = "1 架拍", "側身，手肘抬高"
        elif source_time < 158.75:
            phase, subtitle = "2 加速", "腳、髖、肩依序向前"
        elif source_time < 159.15:
            phase, subtitle = "3 擊球", "在最高、最前方接觸"
        else:
            phase, subtitle = "4 隨揮", "放鬆向前下方完成隨揮"
        return source_time, "分解提示", phase, subtitle
    return 155.30 + (t - 24.0), "完整重播", "連續動作", "把四個階段連成一個節奏"


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    times, images = load_source_frames(args.source, 154.8, 161.5)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    with av.open(str(args.output), mode="w") as output:
        stream = output.add_stream("libx264", rate=FPS)
        stream.width = WIDTH
        stream.height = HEIGHT
        stream.pix_fmt = "yuv420p"
        stream.options = {"crf": "19", "preset": "medium", "movflags": "+faststart"}

        total_frames = 30 * FPS
        for frame_number in range(total_frames):
            timeline_s = frame_number / FPS
            source_time, section, phase, subtitle = map_timeline(timeline_s)
            image = overlay(nearest(times, images, source_time), timeline_s, section, phase, subtitle)
            video_frame = av.VideoFrame.from_image(image)
            video_frame.pts = frame_number
            for packet in stream.encode(video_frame):
                output.mux(packet)
        for packet in stream.encode():
            output.mux(packet)

    print(args.output)
    print(f"duration=30.0 fps={FPS} resolution={WIDTH}x{HEIGHT}")


if __name__ == "__main__":
    main()
