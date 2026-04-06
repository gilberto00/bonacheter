#!/usr/bin/env python3
"""Render BonAcheter App Store icon (1024×1024) — Québec blue identity, sacola + B + traços de lista."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw, ImageFont

QC_BLUE = (0, 61, 165)
QC_BLUE_LIGHT = (13, 86, 207)
LIST_LINE = (0, 61, 165, 88)


def lerp_color(
    a: tuple[int, int, int], b: tuple[int, int, int], t: float
) -> tuple[int, int, int]:
    return (
        int(a[0] + (b[0] - a[0]) * t),
        int(a[1] + (b[1] - a[1]) * t),
        int(a[2] + (b[2] - a[2]) * t),
    )


def draw_diagonal_gradient(
    img: Image.Image, c0: tuple[int, int, int], c1: tuple[int, int, int]
) -> None:
    w, h = img.size
    px = img.load()
    for y in range(h):
        for x in range(w):
            t = x / w * 0.42 + y / h * 0.58
            t = max(0.0, min(1.0, t))
            px[x, y] = lerp_color(c0, c1, t)


def main() -> None:
    out = (
        Path(__file__).resolve().parents[1]
        / "BonAcheter"
        / "Assets.xcassets"
        / "AppIcon.appiconset"
        / "Icon-1024.png"
    )
    scale = 4
    size = 1024 * scale
    img = Image.new("RGB", (size, size), QC_BLUE)
    draw_diagonal_gradient(img, QC_BLUE_LIGHT, QC_BLUE)
    draw = ImageDraw.Draw(img)

    cx, cy = size // 2, size // 2
    bag_w = int(size * 0.52)
    bag_h = int(size * 0.54)
    body_top = cy - int(bag_h * 0.06)
    x0 = cx - bag_w // 2
    x1 = cx + bag_w // 2
    y0 = body_top
    y1 = body_top + bag_h
    corner = int(bag_w * 0.11)

    # Asa: semicírculo superior — corda alinhada ao topo do corpo (PIL: 0°→180° = metade superior)
    handle_w = int(bag_w * 0.52)
    handle_h = int(bag_h * 0.30)
    hx0 = cx - handle_w // 2
    hx1 = cx + handle_w // 2
    hy0 = y0 - handle_h // 2
    hy1 = y0 + handle_h // 2
    draw.pieslice([hx0, hy0, hx1, hy1], 0, 180, fill=(255, 255, 255))

    draw.rounded_rectangle([x0, y0, x1, y1], radius=corner, fill=(255, 255, 255))

    # Traços de lista (sugestão “lista partilhada”)
    line_layer = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    ld = ImageDraw.Draw(line_layer)
    line_w = int(bag_w * 0.62)
    line_h = max(8, int(size * 0.013))
    base_y = y0 + int(bag_h * 0.17)
    gap = int(bag_h * 0.062)
    for i in range(3):
        wline = line_w if i < 2 else int(line_w * 0.7)
        lx = cx - wline // 2
        ly = base_y + i * gap
        ld.rounded_rectangle(
            [lx, ly, lx + wline, ly + line_h],
            radius=line_h // 2,
            fill=LIST_LINE,
        )
    img = Image.alpha_composite(img.convert("RGBA"), line_layer).convert("RGB")
    draw = ImageDraw.Draw(img)

    font_path = "/System/Library/Fonts/Supplemental/Arial Rounded Bold.ttf"
    try:
        font = ImageFont.truetype(font_path, int(size * 0.255))
    except OSError:
        font = ImageFont.truetype(
            "/System/Library/Fonts/Supplemental/Arial Bold.ttf", int(size * 0.255)
        )

    ch = "B"
    bbox = draw.textbbox((0, 0), ch, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    text_x = cx - tw // 2 - bbox[0]
    text_y = y0 + int(bag_h * 0.44) - th // 2
    draw.text((text_x, text_y), ch, font=font, fill=QC_BLUE)

    img = img.resize((1024, 1024), Image.Resampling.LANCZOS)
    img.save(out, "PNG", optimize=True)
    print(f"Wrote {out}")


if __name__ == "__main__":
    main()
