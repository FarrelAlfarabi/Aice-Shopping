"""Builds assets/fonts/ZhSubset.ttf: only the Chinese characters the app uses.
Source: WenQuanYi Zen Hei (GPLv2 with the font embedding exception).
Run: python3 tool/make_zh_font.py  (needs fonttools; re-run after editing lib/l10n/zh.dart)"""
import re, sys
from fontTools import subset
from fontTools.ttLib import TTFont, TTCollection

SRC = '/usr/share/fonts/truetype/wqy/wqy-zenhei.ttc'
text = open('lib/l10n/zh.dart', encoding='utf-8').read()
extra = '，。：；！？（）、“”‘’…·—「」《》【】0123456789%+-:/ '
chars = sorted(set(c for c in text + extra if ord(c) > 127 or c in extra))
font = TTCollection(SRC).fonts[0]
opts = subset.Options()
opts.layout_features = []
opts.name_IDs = [1, 2, 3, 4, 6]
opts.notdef_outline = True
sub = subset.Subsetter(opts)
sub.populate(text=''.join(chars))
sub.subset(font)
font.save('assets/fonts/ZhSubset.ttf')
print(len(chars), 'characters')
