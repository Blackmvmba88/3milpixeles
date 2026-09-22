#!/usr/bin/env python3
"""Generate the canonical 3milpixeles application icon.

The icon is generated from code so local builds and GitHub Actions never depend
on an unpublished binary asset.
"""

from pathlib import Path
from PIL import Image, ImageDraw, ImageFilter, ImageFont

SIZE = 1024
OUT = Path(__file__).resolve().parents[1] / "assets" / "icon.png"

PURPLE = (128, 35, 255, 255)
VIOLET = (183, 82, 255, 255)
GREEN = (106, 255, 67, 255)
DARK = (10, 4, 24, 255)
WHITE = (245, 245, 255, 255)


def rounded_mask(size: int, radius: int) -> Image.Image:
    mask = Image.new("L", (size, size), 0)
    ImageDraw.Draw(mask).rounded_rectangle(
        (0, 0, size - 1, size - 1), radius=radius, fill=255
    )
    return mask


def glow_layer(base: Image.Image, shape: Image.Image, radius: int = 20, opacity: int = 180):
    blur = shape.filter(ImageFilter.GaussianBlur(radius))
    if opacity != 255:
        alpha = blur.getchannel("A").point(lambda p: p * opacity // 255)
        blur.putalpha(alpha)
    base.alpha_composite(blur)
    base.alpha_composite(shape)


def font(size: int):
    candidates = [
        "/System/Library/Fonts/Supplemental/Arial Bold.ttf",
        "/System/Library/Fonts/Helvetica.ttc",
        "/Library/Fonts/Arial Bold.ttf",
        "/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf",
    ]
    for path in candidates:
        try:
            return ImageFont.truetype(path, size)
        except OSError:
            pass
    return ImageFont.load_default()


def main():
    OUT.parent.mkdir(parents=True, exist_ok=True)

    img = Image.new("RGBA", (SIZE, SIZE), DARK)
    px = img.load()

    # Purple-black radial/diagonal background.
    for y in range(SIZE):
        for x in range(SIZE):
            dx = (x - SIZE * 0.5) / SIZE
            dy = (y - SIZE * 0.45) / SIZE
            radial = max(0.0, 1.0 - (dx * dx + dy * dy) * 2.6)
            sweep = max(0.0, 1.0 - abs((x + y) / SIZE - 1.08) * 2.1)
            r = int(9 + 25 * radial + 16 * sweep)
            g = int(4 + 4 * radial)
            b = int(23 + 48 * radial + 34 * sweep)
            px[x, y] = (r, g, b, 255)

    mask = rounded_mask(SIZE, 170)
    img.putalpha(mask)

    # Curved translucent ribbons.
    ribbons = Image.new("RGBA", img.size, (0, 0, 0, 0))
    rd = ImageDraw.Draw(ribbons)
    rd.arc((-260, -220, 1280, 1250), 205, 345, fill=(119, 27, 255, 70), width=115)
    rd.arc((-120, 90, 1160, 1270), 190, 335, fill=(170, 38, 255, 45), width=92)
    rd.arc((80, -420, 1350, 930), 120, 250, fill=(96, 26, 210, 55), width=105)
    img.alpha_composite(ribbons)

    # Outer neon rim.
    rim = Image.new("RGBA", img.size, (0, 0, 0, 0))
    rdraw = ImageDraw.Draw(rim)
    rdraw.rounded_rectangle((24, 24, 999, 999), radius=155, outline=VIOLET, width=8)
    glow_layer(img, rim, 20, 180)

    crop = (255, 230, 770, 720)
    handles = [(255, 230), (770, 230), (255, 720), (770, 720)]

    # Crop frame.
    frame = Image.new("RGBA", img.size, (0, 0, 0, 0))
    fd = ImageDraw.Draw(frame)
    fd.line((300, 255, 725, 255), fill=GREEN, width=11)
    fd.line((300, 695, 725, 695), fill=GREEN, width=11)
    fd.line((280, 280, 280, 670), fill=GREEN, width=11)
    fd.line((745, 280, 745, 670), fill=GREEN, width=11)
    glow_layer(img, frame, 18, 180)

    # Picture tile.
    picture = Image.new("RGBA", img.size, (0, 0, 0, 0))
    pd = ImageDraw.Draw(picture)
    pd.rounded_rectangle((330, 305, 695, 625), radius=36, fill=(20, 8, 48, 230), outline=VIOLET, width=15)
    pd.ellipse((400, 360, 495, 455), fill=(150, 255, 105, 230))
    pd.polygon([(345, 600), (440, 505), (530, 600)], fill=(120, 48, 220, 255))
    pd.polygon([(455, 600), (575, 430), (690, 600)], fill=(150, 79, 236, 255))
    pd.line([(345, 600), (440, 505), (530, 600)], fill=(171, 255, 108, 255), width=8)
    pd.line([(455, 600), (575, 430), (690, 600)], fill=(171, 255, 108, 255), width=8)
    glow_layer(img, picture, 14, 110)

    # Handles and alignment ticks.
    nodes = Image.new("RGBA", img.size, (0, 0, 0, 0))
    nd = ImageDraw.Draw(nodes)
    for x, y in handles:
        nd.rounded_rectangle((x - 30, y - 30, x + 30, y + 30), radius=12, fill=GREEN, outline=WHITE, width=8)
        nd.line((x, y - 78, x, y - 48), fill=VIOLET, width=8)
        nd.line((x, y + 48, x, y + 78), fill=VIOLET, width=8)
        nd.line((x - 78, y, x - 48, y), fill=VIOLET, width=8)
        nd.line((x + 48, y, x + 78, y), fill=VIOLET, width=8)
    glow_layer(img, nodes, 15, 190)

    # Expand arrow.
    arrow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    ad = ImageDraw.Draw(arrow)
    ad.line((605, 410, 680, 335), fill=GREEN, width=24)
    ad.line((635, 335, 680, 335), fill=GREEN, width=24)
    ad.line((680, 335, 680, 380), fill=GREEN, width=24)
    glow_layer(img, arrow, 16, 180)

    # Resolution text.
    td = ImageDraw.Draw(img)
    label = "3000 × 3000"
    ft = font(86)
    bbox = td.textbbox((0, 0), label, font=ft)
    tx = (SIZE - (bbox[2] - bbox[0])) // 2
    ty = 795

    text_glow = Image.new("RGBA", img.size, (0, 0, 0, 0))
    tgd = ImageDraw.Draw(text_glow)
    tgd.text((tx, ty), label, font=ft, fill=GREEN)
    img.alpha_composite(text_glow.filter(ImageFilter.GaussianBlur(18)))
    td.text((tx, ty), label, font=ft, fill=GREEN)

    # Final rounded mask after glow.
    img.putalpha(mask)
    img.convert("RGB").save(OUT, quality=96)
    print(f"Generated {OUT}")


if __name__ == "__main__":
    main()
