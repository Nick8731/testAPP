from __future__ import annotations

import argparse
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parent
sys.path.insert(0, str(ROOT / ".deps"))

import av  # type: ignore  # noqa: E402
import numpy as np  # noqa: E402
from PIL import Image  # noqa: E402


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("video", type=Path)
    parser.add_argument("--step", type=int, default=3)
    args = parser.parse_args()

    scores: list[tuple[float, float]] = []
    previous: np.ndarray | None = None
    with av.open(str(args.video)) as container:
        stream = container.streams.video[0]
        for index, frame in enumerate(container.decode(stream)):
            if index % args.step:
                continue
            image = frame.to_image().convert("L").resize((90, 160), Image.Resampling.BILINEAR)
            current = np.asarray(image, dtype=np.float32)
            if previous is not None:
                score = float(np.mean(np.abs(current - previous)))
                time_s = float(frame.pts * frame.time_base) if frame.pts is not None else index / float(stream.average_rate)
                scores.append((time_s, score))
            previous = current

    ranked = sorted(scores, key=lambda item: item[1], reverse=True)
    selected: list[tuple[float, float]] = []
    for time_s, score in ranked:
        if all(abs(time_s - kept_time) >= 2.5 for kept_time, _ in selected):
            selected.append((time_s, score))
        if len(selected) >= 18:
            break
    selected.sort()
    for time_s, score in selected:
        print(f"{time_s:8.3f} {score:8.3f}")


if __name__ == "__main__":
    main()
