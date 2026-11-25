# Progress log

Newest entry first. Source of truth for scope is `master-plan.md`.

## 2026-11-25 (remaining features, no database)
- Farrel: add the rest of the features without a DB. Supabase block (B0b) stays out. All data is local sample data, state lives on the device.
- Gap check against the plan: cart, voucher, checkout, tracking, late guarantee, report a problem, search, Tanya AI, history and profile already existed. Missing:
  - Mix pack builder (the optional wow feature): pick 6, 8 or 12 cones or sticks for a set price. Prices are in `pricing.dart` only.
  - Order detail screen with "Pesan lagi" (re-order). Mix packs cannot be re-ordered, the screen says how many items were skipped.
  - Notifications screen with unread count (badge on the Profil tab). A placed order adds one.
  - Saved addresses: add and delete (device only). The address picker uses the same list.
  - "Tentang demo ini": what really works and what is sample.
- Assumptions: set prices 6 = Rp31.000, 8 = Rp41.000, 12 = Rp60.000 (sample); mix pack is not a cone, so no Beli 3 discount on it; Reset demo restores addresses, notices and mix packs.
- Not built: live data change moment (needs Supabase), skeleton loading (nothing loads from a network).
- Tests: 44 of 44 pass.

## 2026-11-24 (more listings)
- Farrel: more listings in every category, then merge to main.
- Catalog grew from 13 to 30 sample products: cone 8, stik 4, tub 5, yoghurt 3, minuman 4, paket 5. New photos are colour variants of the existing ones (taro, mangga, mint, stroberi, matcha, dark) and bundle collages. All still "contoh".
- Home gained "Rasa baru" and "Minuman dingin" shelves.
- Bigma guidebook (base v1.1 + Aice edition) applied: config.dart with sampleData and enabledBrands {'aice'}, Brand separate from Store, guard tests (flags, banned claims, photo files), 360 px + large text layout test (fixed real overflows), no service worker (--pwa-strategy=none), README with glossary, LICENSE all rights reserved.
- Tests: 23 of 23 pass.

## 2026-11-24 (UI refresh: photo buttons, motion, faster load)
- Farrel: UI felt static and slow; use Astro's photo-on-button style as the reference.
- Photos: 8 JPGs (530 KB, 800px) replaced by WebPs (74 KB, 400px). Backgrounds cleaned to pure white so they melt into pastel tiles (multiply blend), no cut-out files needed.
- Home: photo category tiles, photo search chips, photo banners with floating product, photo collection tiles, Beli 3 cone progress card, product cards with + that turns into a - n + stepper. Press-scale on every image button, staggered entrance, photo flies into the product page, cart badge pops.
- Load: removed the fake 1.1s splash; HTML splash shows instantly while Flutter loads; preload of app code and photos; all photos cached at start; unused Cupertino font dropped.
- Not changed: Flutter itself still downloads about 2.9 MB (gzip) on first visit. That is the floor for Flutter web.
- Tests: 17 of 17 pass.

## 2026-11-23 (night, plan review)
- master-plan.md v0.5 after a critical review. Main findings:
  - Time: blocks add up to about 25h plus 3h buffer, so about 4 focused days. 2 days does not fit even the never-cut list. Time check table added to section 4.
  - Build order: report a problem (never cut) now comes before search and Tanya AI (cuttable).
  - Cut order: decoration (collection tiles, Produk Serupa) goes earlier, Tanya AI goes last.
  - Missing pieces added: order placed screen, delivered state, empty and error states, demo controls (speed, make late, reset), phone frame on laptop.
  - New tech decisions TD-14 to TD-18 (one seed file, pick data source once, demo clock, Rupiah format, phone frame). New risks R-11 to R-14.
  - New UI preview block before B0. The preview is next.
- Still no code. OQ-13 (Supabase project) is the only blocker for B0b.

## 2026-11-23 (evening, update 2)
- Farrel: no login, referral, coins or wallet for now.
- master-plan.md v0.4: TD-11 confirmed, OQ-14 and D-7 closed, features 28 and 29 marked out for now.
- Still no code. Waiting on Farrel for OQ-13 (which Supabase project, orders on device or in Supabase) before B0b.

## 2026-11-23 (evening)
- Farrel decided: use Supabase (not local mock data), use placeholders for Aice logos and photos, no local folders for tracking, no meeting date yet.
- master-plan.md v0.3: TD-2 rewritten with a bundled-copy fallback, new risk R-9 (Supabase failing live), new block B0b, OQ-13 to OQ-15, D-3 closed.

## 2026-11-23 (later)
- Farrel: no meeting date yet. Astro feature inventory PDF supplied via Drive.
- master-plan.md v0.2: Astro copy list added, OQ-2 closed, OQ-10 to OQ-12 and D-4 to D-7 added.

## 2026-11-23
- Repo was empty. master-plan.md v0.1 written. No code yet.
