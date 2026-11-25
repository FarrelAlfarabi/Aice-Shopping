# Design rules (consumer app)

One small set of rules for every consumer screen. The shared pieces live in `lib/ui.dart`.
Reference for patterns only: common grocery apps (Material 3 and iOS grouped lists). We copy no other app's name, logo, colours, icons or screens.

## Rules
- **Spacing**: only `Sp.xs/s/m/l/xl` = 4, 8, 12, 16, 24. 16 px side margin. 24 px between sections.
- **Type**: `tH2` page title (24, bold), `tH3` section title (17, bold), `tBody` rows and text (15, normal), `tMuted` helper text (13). Bold only for titles and prices (`tPrice`). No weight above 700.
- **One card style**: `Panel` (white, 16 radius, 1 px light border, no shadow). Product cards use a soft shadow and no border. Never both.
- **No card inside a card.** A test fails if a bordered box (200 px or wider) sits inside another one (`test/walk.dart`, run by `layout_test` and `lang_test` in all 3 languages).
- **Lists**: section title, then one `ListGroup` with `ListRow` / `OptionTile` rows. Rows have no border of their own. Dividers only between rows of one group, never next to a border.
- **Selected state**: a check mark (`OptionTile`) or a filled chip (`SmallChip`). No extra box, no thicker border.
- **No repeated labels**: under a "Cara bayar" title the row shows only the method (`PaymentRow(label: false)`).
- **Tap targets**: at least 44 px (chips, steppers, quick-add, rows 56 px).
- **Beranda**: photos lead. Section titles at most 3 words, no helper paragraphs, one Tanya AI entry (the floating button).
- **Demo labelling**: the DEMO strip on every screen and the About screen say the data is sample data. Labels and names do not carry "(contoh)". Safety notes about money, codes and AI answers keep their wording.

## Real product photos
Two products use real photos sent by Farrel (cropped, 400 px WebP, about 14 KB each):
- `assets/products/cup-original.webp`: plain yogurt cup 100 ml. The photo shows another brand (Kaluli). The national emblem and the "resmi" line were painted out.
- `assets/products/frozen-naget.webp`: chicken nugget pack 250 g. The real Aice logo was painted out (guidebook: no real logo).

To swap a photo: replace the file with a 400 x 400 WebP on a pure white background, or point the product's `photo:` in `lib/data.dart` to another file. All photo files are listed in `_tileByPhoto` in `lib/ui.dart`.

## Screenshots
`SHOTS=1 flutter test test/shots_test.dart --update-goldens` writes every consumer screen at 360 px in ID, EN and ZH to `test/shots/` (git-ignored).

## Categories
- 7 shelves, in this order: Yogurt, Frozen Food, Es Krim, Sayur, Sembako, Minuman, Snack (`categories` in `lib/data.dart`).
- Each product keeps its kind (`category`: cone, stick, icecup, tub, mochi, bundle, cup, frozen, drink, veg, staple, snack). `kindGroup` maps a kind to its shelf. Inside Es Krim the search screen shows kind chips (Cone, Stik, Cup, Tub, Mochi, Paket).
- Sayur, Sembako, Snack and some drinks are brand `toko` (the store's own goods), never `aice`. A guard test checks this.
- Cold-chain tags and the "Garansi Tidak Meleleh" row show only for `frozen` and `chilled` storage. Sayur is `fresh`, Sembako and Snack are `room`.
- New items use flat drawn tiles made by `tool/make_tiles.py` (Pillow, 400 px WebP on white, about 4 KB each). Swap any of them for a real photo the same way as above.

## Map address picker (DEMO)
- `lib/map_picker.dart` (screen) and `lib/places.dart` (data). Opened from "Alamat dan toko" > "Pilih di peta" and from Profil > Alamat tersimpan > Tambah.
- A drawn 8 x 8 km map of Jakarta Barat. No real map service, API key or location permission.
- Search box with live suggestions, drag and pinch or wheel to move and zoom, centre pin, "Lokasi saya" button.
- The address, nearest store, distance and delivery time update as the pin moves. Pins more than 5 km from every store cannot be saved.
- "Gunakan lokasi ini" saves the address to Alamat tersimpan, picks the nearest store and shows the distance on Beranda.
