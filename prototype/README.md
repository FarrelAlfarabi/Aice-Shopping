# Aice Shopping (demo prototype)

Clickable Flutter web demo. Not official Aice software. All data is sample data ("Contoh").

## Build and deploy
- Flutter 3.35.5.
- `flutter test`, then `./tool/build_web.sh` (builds with `--no-web-resources-cdn` so the engine and fonts come from our own host, copies to `deploy/`, drops unused files). Vercel serves `deploy/`.
- `deploy/vercel.json` sets cache headers for `canvaskit/`, `assets/`, `icons/` (1 day or less, because those paths are not versioned).
- Roboto is bundled in `assets/fonts/` (Latin subset) so nothing is downloaded from Google at start-up.
- `--pwa-strategy=none`: no service worker, so a new deploy shows on the next load (guidebook 5.4 / 6.3).

## Where things live
- `lib/config.dart`: switches (`sampleData`, `enabledBrands`). Pinned by `test/guard_test.dart`.
- `lib/data.dart`: sample brands, products, stores, addresses.
- `lib/pricing.dart`: cart maths, vouchers, delivery fee, mix pack set prices.
- `lib/screens_c.dart`: mix pack builder, order detail (re-order), notifications, about screen.
- `assets/products/`: 400 px WebP photos with a pure white background (shown on pastel tiles).
- Tests: `logic_test` (cart, vouchers, tracking), `features_test` (mix pack, re-order, notifications, addresses), `intro_test` (main flow), `layout_test` (360 px, large text), `guard_test` (flags, banned claims, photos).

## Glossary
- Brand: who makes the product (only Aice is on).
- Store (outlet): where an order is packed. A store sells products of the brands it lists.
- Product / SKU: one item for sale, with a size and price.
- Cart: items picked before checkout. Order: a placed cart.
- Voucher: a code that lowers the price. Delivery slot: when the order arrives.
