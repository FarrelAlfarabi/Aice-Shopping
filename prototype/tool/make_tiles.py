# Flat illustrated product tiles, 400 px WebP on pure white (multiplied onto pastel in the app).
import sys
from PIL import Image, ImageDraw
OUT = sys.argv[1]
S = 800
def canvas():
    im = Image.new('RGB', (S, S), 'white'); return im, ImageDraw.Draw(im)
def save(im, name):
    im.resize((400, 400), Image.LANCZOS).save(f'{OUT}/{name}.webp', 'WEBP', quality=82, method=6)
def shadow(d, cx=400, y=690, w=250):
    d.ellipse([cx-w, y-22, cx+w, y+22], fill='#ececec')

def bag(name, body, band, top):
    im, d = canvas(); shadow(d)
    d.rounded_rectangle([210, 190, 590, 690], 50, fill=body, outline='#c3ccd8', width=5)
    d.polygon([(220, 200), (580, 200), (560, 150), (240, 150)], fill=top)
    for x in range(250, 560, 40): d.line([(x, 150), (x+10, 200)], fill=body, width=6)
    d.rounded_rectangle([210, 380, 590, 520], 0, fill=band)
    d.ellipse([340, 405, 460, 495], fill='white')
    d.ellipse([370, 430, 430, 470], fill=band)
    save(im, name)

def bottle(name, liquid, cap, wide=False, label=None):
    im, d = canvas(); shadow(d, w=170)
    w = 150 if wide else 115
    d.rounded_rectangle([400-w, 300, 400+w, 690], 46, fill=liquid)
    d.polygon([(400-w+10, 310), (400+w-10, 310), (440, 200), (360, 200)], fill=liquid)
    d.rounded_rectangle([350, 140, 450, 210], 14, fill=cap)
    d.rounded_rectangle([400-w+30, 330, 400-w+55, 640], 12, fill='#ffffff80')
    if label: d.rectangle([400-w, 430, 400+w, 560], fill=label)
    save(im, name)

def cup(name, body, lid, dome=None, tub=False):
    im, d = canvas(); shadow(d, w=210)
    if tub:
        d.polygon([(220, 330), (580, 330), (550, 680), (250, 680)], fill=body)
        d.rounded_rectangle([200, 290, 600, 345], 20, fill=lid)
        d.rectangle([240, 450, 560, 540], fill='white')
    else:
        if dome: d.pieslice([250, 170, 550, 470], 180, 360, fill=dome)
        d.rounded_rectangle([235, 300, 565, 345], 18, fill=lid)
        d.polygon([(255, 340), (545, 340), (505, 680), (295, 680)], fill=body)
        d.rectangle([280, 470, 520, 540], fill='white')
    save(im, name)

def leafy(name, leaf, stem, thin=False):
    im, d = canvas(); shadow(d, w=200)
    for i, (dx, ang) in enumerate([(-110, -1), (-40, 0), (40, 0), (110, 1)]):
        cx = 400 + dx
        lw = 70 if thin else 105
        top = 140 + abs(dx) * 0.6
        d.ellipse([cx - lw + ang*40, top, cx + lw + ang*40, top + (330 if thin else 300)], fill=leaf[i % 2])
        d.line([(cx + ang*40, top + 60), (400 + dx*0.2, 640)], fill=stem, width=14)
    d.rounded_rectangle([340, 520, 460, 580], 16, fill='#c9a46a')
    save(im, name)

def carrots(name):
    im, d = canvas(); shadow(d)
    for dx, rot in [(-120, 0), (0, 0), (120, 0)]:
        cx = 400 + dx
        d.polygon([(cx-55, 300), (cx+55, 300), (cx, 680)], fill='#f28a24')
        for y in range(360, 640, 70): d.line([(cx-30, y), (cx-5, y+8)], fill='#d86f10', width=8)
        for a in (-40, 0, 40): d.ellipse([cx+a-26, 170, cx+a+26, 320], fill='#4caf50')
    save(im, name)

def tomatoes(name):
    im, d = canvas(); shadow(d)
    for cx, cy, r in [(290, 520, 140), (510, 520, 140), (400, 360, 140)]:
        d.ellipse([cx-r, cy-r*0.9, cx+r, cy+r*0.9], fill='#e53935')
        d.ellipse([cx-r*0.55, cy-r*0.6, cx-r*0.25, cy-r*0.3], fill='#ef7370')
        d.polygon([(cx-40, cy-r*0.85), (cx, cy-r*0.65), (cx+40, cy-r*0.85), (cx, cy-r*1.05)], fill='#388e3c')
    save(im, name)

def broccoli(name):
    im, d = canvas(); shadow(d, w=180)
    d.polygon([(360, 420), (440, 420), (470, 680), (330, 680)], fill='#8bc34a')
    for cx, cy, r in [(280, 360, 110), (520, 360, 110), (400, 280, 130), (340, 440, 90), (460, 440, 90)]:
        d.ellipse([cx-r, cy-r, cx+r, cy+r], fill='#2e7d32')
    for cx, cy in [(300, 320), (420, 240), (520, 330), (380, 400)]:
        d.ellipse([cx-24, cy-24, cx+24, cy+24], fill='#43a047')
    save(im, name)

def eggs(name):
    im, d = canvas(); shadow(d, w=280)
    d.rounded_rectangle([130, 500, 670, 660], 30, fill='#d7c4a3')
    for i, cx in enumerate([220, 340, 460, 580]):
        d.ellipse([cx-62, 330, cx+62, 540], fill='#f3d5b0' if i % 2 else '#eecba0')
        d.ellipse([cx-35, 370, cx-10, 420], fill='#fbe9d4')
    save(im, name)

def pouch(name, body, band, inner):
    im, d = canvas(); shadow(d, w=210)
    d.polygon([(230, 180), (570, 180), (600, 680), (200, 680)], fill=body)
    for x in range(230, 571, 34): d.polygon([(x, 180), (x+17, 160), (x+34, 180)], fill=body)
    d.ellipse([290, 330, 510, 550], fill=band)
    for cx, cy in [(360, 410), (440, 400), (400, 470)]:
        d.ellipse([cx-50, cy-36, cx+50, cy+36], fill=inner)
    save(im, name)

def wafer(name):
    im, d = canvas(); shadow(d, w=260)
    d.rounded_rectangle([150, 300, 650, 600], 30, fill='#7b4a2b')
    d.rounded_rectangle([150, 380, 650, 520], 0, fill='#f2c14e')
    for i, cx in enumerate([270, 400, 530]):
        d.rounded_rectangle([cx-55, 400, cx+55, 500], 8, fill='#d99b52')
        for y in (420, 450, 480): d.line([(cx-45, y), (cx+45, y)], fill='#b97a35', width=5)
    save(im, name)

def biscuits(name):
    im, d = canvas(); shadow(d, w=260)
    for cx, cy in [(300, 470), (500, 470), (400, 350)]:
        d.ellipse([cx-125, cy-125, cx+125, cy+125], fill='#e6b673')
        d.ellipse([cx-100, cy-100, cx+100, cy+100], outline='#c99350', width=8)
        for dx, dy in [(-40, -30), (30, -40), (0, 20), (45, 35), (-45, 40)]:
            d.ellipse([cx+dx-10, cy+dy-10, cx+dx+10, cy+dy+10], fill='#fff4dc')
    save(im, name)

def jar(name, lid, inner):
    im, d = canvas(); shadow(d, w=200)
    d.rounded_rectangle([230, 260, 570, 680], 60, fill='#e7eef3')
    d.rounded_rectangle([250, 200, 550, 280], 20, fill=lid)
    for cx, cy in [(320, 360), (420, 340), (500, 400), (330, 470), (440, 470), (360, 570), (480, 570)]:
        d.pieslice([cx-55, cy-45, cx+55, cy+65], 200, 340, fill=inner, width=0)
        d.arc([cx-55, cy-45, cx+55, cy+65], 190, 350, fill=inner, width=30)
    save(im, name)

def mochi(name, a, b, c):
    im, d = canvas(); shadow(d, w=260)
    d.ellipse([140, 540, 660, 660], fill='#f0f0f0')
    for (cx, cy), col in zip([(280, 500), (520, 500), (400, 400)], [a, b, c]):
        d.ellipse([cx-130, cy-115, cx+130, cy+115], fill=col)
        d.ellipse([cx-80, cy-80, cx-30, cy-40], fill='#ffffffaa')
    save(im, name)

def dimsum(name):
    im, d = canvas(); shadow(d, w=260)
    d.rounded_rectangle([150, 470, 650, 650], 30, fill='#d8a45c')
    for y in (520, 580): d.line([(160, y), (640, y)], fill='#b98440', width=8)
    for cx in (250, 400, 550):
        d.ellipse([cx-80, 330, cx+80, 500], fill='#fbf1df')
        d.polygon([(cx-25, 340), (cx+25, 340), (cx, 300)], fill='#fbf1df')
        d.ellipse([cx-18, 345, cx+18, 375], fill='#f08a5d')
    save(im, name)

def fries(name):
    im, d = canvas(); shadow(d, w=200)
    for i, x in enumerate(range(260, 545, 38)):
        d.rounded_rectangle([x, 170 + (i % 3) * 30, x + 30, 480], 8, fill='#f6c445')
    d.polygon([(220, 400), (580, 400), (540, 690), (260, 690)], fill='#e53935')
    d.ellipse([340, 480, 460, 600], fill='#ffd54f')
    save(im, name)

def bakso(name):
    im, d = canvas(); shadow(d, w=230)
    d.rounded_rectangle([190, 190, 610, 690], 40, fill='#e9f3fb')
    d.rounded_rectangle([190, 190, 610, 290], 40, fill='#1e88e5')
    for cx, cy in [(300, 420), (420, 400), (520, 450), (340, 540), (470, 570)]:
        d.ellipse([cx-62, cy-58, cx+62, cy+58], fill='#9c6b4e')
        d.ellipse([cx-35, cy-35, cx-10, cy-12], fill='#b88a6b')
    save(im, name)

def coffee(name):
    im, d = canvas(); shadow(d, w=180)
    d.polygon([(260, 250), (540, 250), (500, 690), (300, 690)], fill='#e9e1d6')
    d.polygon([(275, 420), (525, 420), (500, 690), (300, 690)], fill='#a8744a')
    d.polygon([(262, 270), (538, 270), (528, 380), (272, 380)], fill='#f5efe6')
    d.rounded_rectangle([240, 220, 560, 270], 18, fill='#5d4037')
    d.rectangle([430, 120, 450, 230], fill='#5d4037')
    save(im, name)

bag('staple-beras', '#f7f1e1', '#4caf50', '#e8dcc0')
bag('staple-gula', '#e3eaf3', '#1e88e5', '#e5e9ee')
bag('staple-tepung', '#f1e6dc', '#e53935', '#e0d2c4')
bottle('staple-minyak', '#f9c623', '#e53935', wide=True, label='#ffffff')
eggs('staple-telur')
leafy('veg-bayam', ['#2e7d32', '#43a047'], '#7cb342')
leafy('veg-kangkung', ['#558b2f', '#7cb342'], '#9ccc65', thin=True)
carrots('veg-wortel')
tomatoes('veg-tomat')
broccoli('veg-brokoli')
bottle('drink-teh', '#c8781f', '#2e7d32', label='#ffffff')
bottle('drink-air', '#cfe8fb', '#1e88e5', label='#1e88e5')
coffee('drink-kopi')
bottle('yog-drink', '#f8bbd0', '#ec407a', label='#ffffff')
cup('yog-greek', '#dfe5f5', '#3949ab', tub=True)
pouch('snack-keripik', '#e53935', '#ffd54f', '#f6b93b')
jar('snack-mete', '#c62828', '#e9c48f')
wafer('snack-wafer')
biscuits('snack-biskuit')
mochi('mochi-vanila', '#f6e3bd', '#f3dcae', '#f9ebcf')
mochi('mochi-stroberi', '#f8bbd0', '#f48fb1', '#fce4ec')
mochi('mochi-matcha', '#c5e1a5', '#aed581', '#dcedc8')
cup('icup-cokelat', '#6d4c41', '#3e2723', dome='#8d6e63')
cup('icup-vanila', '#fff3c4', '#f9a825', dome='#fff8e1')
dimsum('frozen-dimsum')
fries('frozen-kentang')
bakso('frozen-bakso')
