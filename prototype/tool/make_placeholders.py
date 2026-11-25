"""Draws our own flat placeholder pictures for the chilled and frozen products.
No real logo, brand or pack art is used. Run: python3 tool/make_placeholders.py
Needs Pillow. Output: 400 px WebP on a pure white background (same as the
other product photos)."""
from PIL import Image, ImageDraw, ImageFont
import math, random

S = 1600  # draw big, shrink to 400 for smooth edges
BOLD = '/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf'


def canvas():
    im = Image.new('RGB', (S, S), 'white')
    return im, ImageDraw.Draw(im)


def shadow(d, cx, cy, w, h):
    d.ellipse([cx - w, cy - h, cx + w, cy + h], fill=(232, 236, 242))


def save(im, name):
    im.resize((400, 400), Image.LANCZOS).save(f'assets/products/{name}', 'WEBP', quality=88)


def yogurt_cup():
    im, d = canvas()
    shadow(d, 800, 1420, 520, 70)
    # cup body
    d.polygon([(380, 620), (1220, 620), (1100, 1380), (500, 1380)], fill=(250, 250, 252), outline=(214, 222, 236))
    d.polygon([(386, 640), (1214, 640), (1190, 840), (410, 840)], fill=(11, 95, 216))  # blue band
    f = ImageFont.truetype(BOLD, 150)
    d.text((800, 990), 'Original', font=f, fill=(11, 95, 216), anchor='mm')
    f2 = ImageFont.truetype(BOLD, 90)
    d.text((800, 1150), 'YOGURT  100 ml', font=f2, fill=(85, 98, 122), anchor='mm')
    # lid
    d.ellipse([340, 520, 1260, 720], fill=(11, 95, 216), outline=(10, 63, 150), width=8)
    d.ellipse([440, 560, 1160, 680], fill=(74, 147, 255))
    # chilled dot
    d.ellipse([700, 1230, 900, 1330], fill=(234, 242, 255), outline=(11, 95, 216), width=6)
    d.text((800, 1280), '2-6°C', font=ImageFont.truetype(BOLD, 52), fill=(11, 95, 216), anchor='mm')
    save(im, 'cup-original.webp')


def nugget(d, cx, cy, r, rot):
    random.seed(int(cx * 7 + cy))
    pts = []
    for i in range(14):
        a = i / 14 * 2 * math.pi
        rr = r * (0.82 + 0.22 * random.random())
        pts.append((cx + rr * math.cos(a + rot) * 1.2, cy + rr * math.sin(a + rot)))
    d.polygon(pts, fill=(226, 150, 52), outline=(181, 104, 22))
    for _ in range(26):
        x, y = cx + random.uniform(-r, r) * .8, cy + random.uniform(-r, r) * .6
        d.ellipse([x - 7, y - 7, x + 7, y + 7], fill=(244, 190, 100))


def pack(name, body, accent, label, sub, draw_food):
    im, d = canvas()
    shadow(d, 800, 1450, 460, 60)
    # sealed top and bottom edges, flat pack
    d.rounded_rectangle([420, 230, 1180, 1400], 40, fill=body, outline=accent, width=10)
    for x in range(430, 1170, 36):
        d.line([(x, 236), (x + 18, 290)], fill=accent, width=6)
        d.line([(x, 1344), (x + 18, 1394)], fill=accent, width=6)
    d.rectangle([440, 330, 1160, 470], fill=accent)
    d.text((800, 400), label, font=ImageFont.truetype(BOLD, 98), fill='white', anchor='mm')
    draw_food(d)
    d.rounded_rectangle([470, 1080, 1130, 1210], 30, fill='white')
    d.text((800, 1145), sub, font=ImageFont.truetype(BOLD, 64), fill=accent, anchor='mm')
    d.rounded_rectangle([470, 1235, 1130, 1330], 30, fill=accent)
    d.text((800, 1283), 'SIMPAN BEKU -18°C', font=ImageFont.truetype(BOLD, 56), fill='white', anchor='mm')
    save(im, name)


def food_nugget(d):
    for cx, cy, r, rot in [(660, 700, 150, .3), (930, 760, 160, 1.1), (760, 930, 150, 2.0), (980, 960, 120, 2.6)]:
        nugget(d, cx, cy, r, rot)


def food_tofu(d):
    for i, (cx, cy) in enumerate([(650, 720), (900, 700), (780, 920), (1010, 930)]):
        d.rounded_rectangle([cx - 120, cy - 85, cx + 120, cy + 85], 36, fill=(246, 232, 200), outline=(200, 170, 110), width=6)
        d.ellipse([cx - 14, cy - 14, cx + 14, cy + 14], fill=(210, 180, 120))
        d.ellipse([cx + 40, cy + 20, cx + 62, cy + 42], fill=(210, 180, 120))


def food_sausage(d):
    for i, y in enumerate([700, 810, 920]):
        d.rounded_rectangle([560, y - 42, 1040, y + 42], 42, fill=(205, 110, 80), outline=(150, 70, 50), width=6)
        d.rounded_rectangle([600, y - 28, 1000, y - 8], 10, fill=(228, 150, 120))


yogurt_cup()
pack('frozen-naget.webp', (255, 244, 224), (222, 110, 20), 'Naget Ayam', '250 g', food_nugget)
pack('frozen-tahu.webp', (230, 244, 246), (14, 124, 134), 'Tahu Ikan', '400 g', food_tofu)
pack('frozen-sosis.webp', (255, 236, 232), (180, 60, 50), 'Sosis Ayam', '300 g', food_sausage)
