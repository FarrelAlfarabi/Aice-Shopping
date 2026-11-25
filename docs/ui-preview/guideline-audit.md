# UI preview audit (Bigma guidebook + Web Interface Guidelines)

Guidebook used: Bigma guidebook base v1.1 + Aice edition (full text read from chat, 24 Nov). Web rules: vercel-labs/web-interface-guidelines (fetched 25 Nov).

## Fixed in preview v5
- 4.3 narrow phone: no horizontal overflow at 360 px in ID, EN and ZH on Home, Profil, Pesanan, Alamat, Notifikasi, Cari (checked by script). Tags and "Hemat" chips now wrap.
- 4.4 empty states say what to do next (cart, orders, search). Lists show a count and a Clear button.
- 4.5 confirmations: sign out, reset demo data, open WhatsApp (leaves the app). Button words name the action.
- 4.7 navigation: each tab has a URL (#app-home, #app-cart, #app-orders, #app-profile, #admin-over ...). Back from any tab returns to Home. Esc closes sheets, chat and screens.
- 5.1 flow screens added: address and store pick, search, notifications, order tracking with ETA countdown, "stays frozen" note, late promise (demo), report a problem (melted, wrong, missing; photo placeholder; replace or refund; status).
- 5.2 persistent demo strip: "DEMO · Data contoh · Bukan aplikasi resmi Aice".
- Points on Home: points card under the header (balance, tier, progress), join card for guests.
- Web rules: aria-labels on icon buttons, aria-modal dialogs with focus moved in, aria-live on chat and toast, labels and autocomplete/type/inputmode/spellcheck on fields, placeholders end with an ellipsis, 16 px inputs (no iOS zoom), touch-action manipulation, overscroll-behavior contain, hover states, prefers-reduced-motion, curly quotes, non-breaking spaces in units, Intl.NumberFormat for Rupiah, translate="no" on brand names, image width/height + lazy, main landmark, theme-color.
- Contrast (AA 4.5:1) checked for all text pairs in light and dark: lowest is 4.75 (white on red).

## Still open
- Guidebook 5.4 says no Aice colors. Farrel asked for Aice-like colors; kept in one BRAND THEME block.
- Skip link not added: the artifact page cannot use #main without clashing with the URL routing.
- Chinese copy was not reviewed by a native speaker.
- Admin tabs other than Ikhtisar are light sample tables by request.

## Payment and Profil update (25 Nov)
- Cara bayar picker in cart: Transfer bank (sample account, "Saya sudah transfer" on the order, admin confirms), QRIS (sample QR, confirmed now), E-wallet (sample, confirmed now), COD (pay courier, note shown).
- Order and admin show the method. "Konfirmasi transfer" only appears for bank transfer. Points: bank on admin confirm, QRIS and e-wallet at once, COD when marked selesai.
- Profil default payment (Cara bayar utama) pre-selects the cart choice.
- Profil rebuilt: avatar with initials, tier badge, points, Member card, then groups Akun, Alamat tersimpan, Cara bayar, Bahasa, Notifikasi, Bantuan, Tentang demo ini, then Keluar with confirmation. Icon rows with chevrons, 56 px rows, no overflow at 360 px in ID, EN, ZH.
