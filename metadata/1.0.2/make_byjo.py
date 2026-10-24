#!/usr/bin/env python3
"""Renders the ByJo-style App Store slides (same layout as pola's "App Store 1.0.6 · B" set).

#EBEBEB background, a centered SF Compact Rounded Bold title in the brand red, a Semibold
subtitle under it, and one device running off the bottom edge.

Usage: python3 metadata/1.0.2/make_byjo.py
Reads raw/<device>/<language>/<screen>.png and the captions table in <language>.md.
Writes byjo/<device>/<language>/NN-<screen>.png in upload order.
"""

import re
from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

HERE = Path(__file__).parent
FONT = "/System/Library/Fonts/SFCompactRounded.ttf"
BACKGROUND = (235, 235, 235)
TITLE = (214, 48, 39)  # the red of the app icon's mouth
SUBTITLE = (28, 28, 30)
BEZEL = (22, 22, 24)

LANGUAGES = ["en", "de", "es", "fr", "it"]
SCREENS = ["home", "detail", "fragility", "review", "premortem", "paywall"]

# Canvas sizes App Store Connect accepts: 6.9" iPhone and 13" iPad.
DEVICES = {
    "iphone": dict(size=(1290, 2796), title=156, subtitle=96, top=210, gap=36,
                   device_width=1120, device_top=620, corner=150, bezel=30, island=True),
    "ipad": dict(size=(2064, 2752), title=180, subtitle=110, top=200, gap=40,
                 device_width=1800, device_top=660, corner=90, bezel=40, island=False),
}


def font(size: int, weight: str) -> ImageFont.FreeTypeFont:
    f = ImageFont.truetype(FONT, size)
    f.set_variation_by_name(weight)
    return f


def captions(language: str) -> list[tuple[str, str]]:
    text = (HERE / f"{language}.md").read_text()
    section = text.split("## Screenshot captions (ByJo style)", 1)[1]
    return re.findall(r"^\| \d+ \| (.*?) \| (.*?) \|$", section, re.M)


def fit(draw: ImageDraw.ImageDraw, text: str, size: int, weight: str, max_width: int) -> ImageFont.FreeTypeFont:
    """Shrinks the font until the line fits, so long translations stay on one line."""
    f = font(size, weight)
    while draw.textlength(text, font=f) > max_width and size > 40:
        size -= 4
        f = font(size, weight)
    return f


def framed(capture: Image.Image, spec: dict) -> Image.Image:
    width = spec["device_width"]
    bezel = spec["bezel"]
    screen = capture.resize((width - bezel * 2, round(capture.height * (width - bezel * 2) / capture.width)), Image.LANCZOS)
    radius = spec["corner"]

    frame = Image.new("RGBA", (width, screen.height + bezel * 2), (0, 0, 0, 0))
    draw = ImageDraw.Draw(frame)
    draw.rounded_rectangle((0, 0, frame.width - 1, frame.height - 1), radius=radius + bezel, fill=BEZEL)

    mask = Image.new("L", screen.size, 0)
    ImageDraw.Draw(mask).rounded_rectangle((0, 0, screen.width - 1, screen.height - 1), radius=radius, fill=255)
    frame.paste(screen, (bezel, bezel), mask)

    if spec["island"]:
        island_w, island_h = round(width * 0.29), round(width * 0.085)
        x = (frame.width - island_w) // 2
        y = bezel + round(width * 0.03)
        draw.rounded_rectangle((x, y, x + island_w, y + island_h), radius=island_h // 2, fill=(0, 0, 0))
    return frame


def slide(device: str, language: str, index: int, screen: str, title: str, subtitle: str) -> None:
    spec = DEVICES[device]
    width, height = spec["size"]
    canvas = Image.new("RGB", spec["size"], BACKGROUND)
    draw = ImageDraw.Draw(canvas)
    margin = 80 if device == "iphone" else 120

    title_font = fit(draw, title, spec["title"], "Bold", width - margin * 2)
    sub_font = fit(draw, subtitle, spec["subtitle"], "Semibold", width - margin * 2)
    y = spec["top"]
    draw.text((width / 2, y), title, font=title_font, fill=TITLE, anchor="mt")
    y += spec["title"] + spec["gap"]
    draw.text((width / 2, y), subtitle, font=sub_font, fill=SUBTITLE, anchor="mt")

    capture = Image.open(HERE / "raw" / device / language / f"{screen}.png").convert("RGB")
    phone = framed(capture, spec)
    canvas.paste(phone, ((width - phone.width) // 2, spec["device_top"]), phone)

    out = HERE / "byjo" / device / language
    out.mkdir(parents=True, exist_ok=True)
    canvas.save(out / f"{index:02d}-{screen}.png", optimize=True)


if __name__ == "__main__":
    for device in DEVICES:
        for language in LANGUAGES:
            rows = captions(language)
            for index, (screen, (title, subtitle)) in enumerate(zip(SCREENS, rows), start=1):
                if device == "ipad":
                    subtitle = subtitle.replace("iPhone", "iPad")
                if (HERE / "raw" / device / language / f"{screen}.png").exists():
                    slide(device, language, index, screen, title, subtitle)
            print(f"{device}/{language}")
