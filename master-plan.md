# Master plan: Aice quick commerce demo

**Version:** 0.4 (sprint mode)
**Last updated:** 2026-11-23
**Owner:** Farrel
**Status:** Plan only. No code written. Repo was empty. No app building guidebook found.

> This is a clickable DEMO. Nothing in it is a working system. Every feature below is mocked unless this plan says otherwise. It is not official Aice software and there is no partnership.

---

## 1. Goals

**Near-term goal (the milestone this plan serves):**
Show the Aice team one smooth path on a phone, from a link: pick address and store, browse, add to cart, check out with fake payment, watch the order tracking, report a melted item. It must feel as fast and clean as Astro.

**Long-term goal:**
Aice signs the real project. Later versions add other brands and real integrations.

**Success metrics:**
- The full happy path runs start to finish on a real phone with no crash, no dead button. Target: yes/no, checked by a script and by hand.
- The same path also works when Supabase is switched off (fallback). Target: yes/no.
- Demo link opens on iPhone Safari and Android Chrome. Target: yes/no.
- Time from tapping the link to first screen. Target: **baseline unknown**, see OQ-6.
- Aice signs the real project. Target: **baseline unknown**, outside our control, see OQ-1.

No other targets are set. None are invented.

---

## 2. Scope

### Real now (actually works)
- Screen navigation and all the clicking.
- Reading the sample catalog, stores, banners, vouchers and scripted AI answers **from Supabase** (read only), with an automatic fallback to a copy bundled in the app (see TD-2).
- Cart maths: totals, voucher discount, multi-buy discount, delivery fee, free delivery over a threshold, minimum order.
- Search over the catalog, with a sort and a simple filter.
- Tests (TDD) for the cart maths, voucher and multi-buy rules, fee rules, order status steps, late-delivery rule, search, the scripted AI answers, and the fallback switch.
- Web build on a public link.

### Mocked (looks real, is not)
- Products, prices, photos: **sample data**, labeled "Contoh" in the UI. Photos are drawn placeholders.
- Stores, addresses, distances, open hours: **fictional sample stores**, not real Aice outlets.
- Address picker: a fixed list plus a typed text box. No real map, no GPS.
- Payments (e-wallet, bank transfer, QRIS): fake screens. No money moves.
- Order tracking and ETA countdown: a timer that fakes the steps. No courier is named.
- "Tanya AI" helper: scripted answers. No AI model.
- Late delivery guarantee and report a problem: the flow ends on a confirmation screen. No refund happens.
- Profile, notifications, order history: fixed sample data. There is no login.
- Cart and orders live on the device only. They are **not** written to Supabase (see TD-2, OQ-13).
- Supabase holds sample data only. No real customers, no real data.

### The 9 screen groups (all mocked, in this demo)
1. Onboarding: address, then 3 to 4 sample stores with open hours and distance.
2. Home: promo banners, 6 categories (cones, tubs, sticks, yoghurt, drinks, bundles), best sellers, search bar.
3. Search and "Tanya AI" scripted helper.
4. Product page: picture, price, pack variants, add to cart.
5. Cart: voucher field, delivery fee (free above a threshold), delivery time slot.
6. Checkout: 3 fake payment options.
7. Order tracking: status steps, ETA countdown, "tetap beku" (stays frozen) message.
8. Late delivery guarantee and report a problem (melted or wrong item, replacement or refund request).
9. Order history, saved addresses, profile, notifications.

### Astro features we copy (from the Astro feature inventory, checked by its author on 23 Nov 2026)
Source: `ASTRO_feature_inventory_for_AICE.pdf` in Farrel's Drive. Astro IDs in brackets.

| # | Astro feature | Our demo version | Status |
|---|---|---|---|
| 1 | Delivery promise header on home [H1] | "Tiba dalam 15 Menit" style promise line. Wording is ours, time is a sample. | Mocked, in scope |
| 2 | Always-visible search bar, full-screen search, popular search chips [H2, S1, S2] | Same. Chips are sample words. | In scope |
| 3 | Live results grid while typing [S4] | Same, over the sample catalog. | In scope |
| 4 | Banner carousel with dots [H5] | 3 to 4 Aice-style promo banners. | In scope |
| 5 | Themed collection tiles [H6] | 2 to 3 tiles (for example a party pack). | In scope, cut if short |
| 6 | Category grid [H7] | The 6 categories from the brief. | In scope |
| 7 | Product card: price, old price, % badge, size, quick-add + [P1] | Same. | In scope |
| 8 | Ribbons: Best Seller, Habis (sold out), multi-buy tags [P3, M4] | Best Seller, New, Habis, "Beli 2 Disc." | In scope |
| 9 | Halal mark and BPOM/halal number on product page [P2, P6] | Shown as "sample" placeholders, not real numbers. | In scope, see OQ-10 |
| 10 | Product page: photo gallery, add to cart, description, storage advice [P4, P6] | Same, plus pack variants. | In scope |
| 11 | Free return line [P5] | Not copied. Replaced by the melt guarantee line. | Replaced |
| 12 | Similar products shelf [P7] | "Produk Serupa" row. | In scope, cut if short |
| 13 | Multi-buy discount, mix and match [M1, M2] | Real tested logic: "Beli 3 Diskon 10%" (sample numbers). The inventory calls this the main basket builder. | In scope, **real logic** |
| 14 | Bundles with free gift [M3] | 2 sample bundles (family pack, party pack). | In scope |
| 15 | Sold out stays visible, greyed [M6] | One or two sold-out items. | In scope |
| 16 | Filter sheet [S5] | Sort by price, plus one flavour or type filter. The inventory says Astro only has price sort. | In scope |
| 17 | Bottom tabs: Home, Cart, Orders, Profile [H11] | Same 4 tabs. | In scope |
| 18 | Promo code button in cart [Section 8] | Voucher field with 2 or 3 sample codes. | In scope |
| 19 | Minimum order and delivery fee [Section 8] | Sample minimum order and free-delivery threshold. | In scope, numbers are sample |
| 20 | Delivery options: instant or scheduled slot [Section 8] | Time slot picker. | In scope |
| 21 | Payment: e-wallet and virtual account, no cash [Section 8] | E-wallet, bank transfer, QRIS (fake). No cash option. | In scope |
| 22 | On-time guarantee: fee refunded if more than 10 min late [Section 7] | Our guarantee line and a tested rule. The 10 minute and fee-refund rule is Astro's. Aice's real rule is unknown, so ours is a sample. | In scope, see OQ-11 |
| 23 | Quality guarantee with claim in 24 hours, photo, QR on package [Section 7] | Renamed "Garansi Tidak Meleleh" (melt guarantee). Report a problem flow with photo step (fake) and replacement or refund choice. | In scope |
| 24 | Order history tab [Section 8] | List of 2 or 3 sample orders. | In scope |
| 25 | Order tracking [Section 8, not seen on screen] | Status steps and ETA countdown. Astro does tracking via chat, so this is our design, not a copy. | In scope, our design |
| 26 | In-app support chat [Section 8] | Not built. "Tanya AI" covers help in the demo. | Cut |
| 27 | Install-app banner [H10] | Not built. The demo is the web link itself. | Cut |
| 28 | Phone number login gate at add to cart [Section 6] | **Not built.** Farrel decided: no login for now. | Out for now |
| 29 | Referral, loyalty coins, wallet balance [Sections 7, 8] | **Not built.** Farrel decided: not for now. | Out for now |
| 30 | Sponsored brand zone, FAQ accordion, info pages, service-area form [H8, H9, Section 7] | Not built. Later phase. | Later |

### New for Aice, taken from the inventory's section 9B (not in Astro)
- **Cold chain message and melt guarantee**: in scope (screen groups 7 and 8).
- **Flavour mix pack builder** (pick any 6, 8 or 12 for a set price): **optional wow feature**, only if time is left after B6. It targets the low basket problem the inventory describes.
- Freezer locator, retailer-fulfilled orders, subscription, gifting, kids rewards, reviews and ratings: later phases. Not in the demo.

### What the inventory could NOT confirm
Cart, checkout, payment, order tracking, order history, profile, address picker and in-app chat were **not seen on screen** (Astro forces a login). They come from Astro's FAQ text. Our versions of those screens are our own design, not a copy of Astro's screens. Screens inside the PDF images were not viewed by Claude, only the PDF text was read. See D-2.

### Later phases (not built now)
- Phase 2: real Aice catalog, real stores, real images (needs Aice and trademark clearance).
- Phase 3: real login, real payment gateway, real orders flowing to stores, orders stored in the database.
- Later: referral, loyalty coins and wallet, if Aice wants them.
- Phase 4: other brands. Brand and Store are separate data concepts from day one, but only Aice is shown.

### Out of scope, always for the demo
Real payment, real customer data, claiming a partnership, claiming official Aice software. Copying Astro's name, logo, mascot or artwork.

---

## 3. Users and roles
- **Customer** (the only role built). Browses, orders, tracks, reports problems. No login: the demo opens as a guest.
- **Meeting audience**: the Aice team. They watch Farrel use it, or tap it themselves.
- Store staff, admin, courier, brand owner: **not built.** Later phases. Roles unknown, see OQ-9.

---

## 4. Milestones (sprint mode)

**Deadline: unknown.** Farrel said on 2026-11-23: "no date yet". Hours available are also unknown. The blocks below assume about **2.5 to 3 focused working days** (up from 2 to 3 because Supabase adds work). If the real time is shorter, cut using the cut order. See OQ-1.

Each block is test first: write the failing test, make it pass, then build the screen.

| Block | Work | Done when |
|---|---|---|
| B0 (1h) | Set up Flutter project, theme, Indonesian text, test setup, Vercel deploy of an empty app. | Empty app opens on a phone from a Vercel link. |
| B0b (2h) | Supabase: project, tables (Brand, Store, Product, Variant, Banner, Voucher, AI script), sample data, read-only row security, publishable key only. Data layer with 2 versions behind one interface: Supabase and bundled copy. Tests for the fallback switch. | App reads products from Supabase on the Vercel link, and still shows them when Supabase is blocked. |
| B1 (2h) | Models and cart logic. Tests for cart maths, voucher, multi-buy, fee, threshold, minimum order. | Logic tests pass. |
| B2 (3h) | Onboarding + Home + Product page. | Can reach a product from the first screen. |
| B3 (3h) | Cart + time slot + checkout with 3 fake payments. | Can place a fake order. |
| B4 (3h) | Order tracking, ETA countdown, frozen message. | Tracking runs after checkout. |
| B5 (2h) | Search, filter, scripted "Tanya AI". | 10 or so scripted questions answer well. |
| B6 (2h) | Late delivery guarantee + report a problem flow. | Flow ends on a confirmation screen. |
| B7 (2h) | History, saved addresses, profile, notifications. | All reachable, all sample data. |
| B8 (2h) | Polish, phone test, speed check, Supabase-off test, rehearsal, demo script. | Full run twice with no fault, once with Supabase blocked. |

**Hard feature freeze:** start of B8. After that, only bug fixes. No new screens.

**Cut order (cut from the top first):**
1. Optional mix pack builder
2. Notifications screen
3. Saved addresses management (keep a fixed list)
4. Profile screen
5. "Tanya AI" helper (keep plain search)
6. Collection tiles and "Produk Serupa" row
7. Order history (keep a single sample past order)
8. Bank transfer and QRIS screens (keep e-wallet only)

**Never cut:** onboarding, home, product, cart, checkout, order tracking, report a problem, the fallback switch. These are the story the meeting needs.

---

## 5. Tech decisions

| ID | Decision | Trade-off |
|---|---|---|
| TD-1 | Flutter, mobile first, web build. | One code base and the phone-app feel. Web load is heavier than plain HTML. |
| TD-2 | **Supabase holds the sample catalog, stores, banners, vouchers and AI script. Read only for the app. Cart and orders stay on the device. The app falls back to a bundled copy of the same data if Supabase is slow or fails.** | Shows Aice a real backend shape and lets us change data without a new build. Adds setup time and a new way to fail live (see R-9). The fallback removes that failure from the meeting. Tests run against an in-memory version, so they do not need the network. |
| TD-3 | Brand and Store are separate models and tables. Only Aice shown. | A bit more work now. Saves a rewrite later. |
| TD-4 | State: Riverpod or plain Provider. Pick one in B0 and stay. | Small choice, do not debate it. |
| TD-5 | TDD for logic (cart, voucher, multi-buy, fee, status steps, late rule, search, AI script, fallback). Widget tests for the main flow. | Slower start. Fewer bugs in the meeting. Pixel looks are checked by hand, not by tests. |
| TD-6 | Deploy the built web output to Vercel (build in CI or locally, then deploy). | Vercel's own build step does not have Flutter by default. Needs one extra setup step. See R-3. |
| TD-7 | Product pictures: simple drawn placeholders, no real Aice photos or logos. **Confirmed by Farrel.** | Looks less real. Avoids trademark trouble. See OQ-3. |
| TD-8 | Colors: Aice-like blue and white, as a theme. Exact brand colors unconfirmed. | Close enough for a demo. Not an exact match. |
| TD-9 | UI language: Indonesian. This plan: English. | Code and docs stay plain English. |
| TD-10 | Footer text in the app: "Demo konsep. Bukan aplikasi resmi Aice." | Slightly less polished. Protects against a partnership claim. |
| TD-11 | Guest session, no login, referral, coins or wallet. **Confirmed by Farrel.** | Fewer screens, less to break. A real app needs phone login later. |
| TD-12 | Supabase security: row security on every table, select-only policies for the public key, only the publishable key in the app, no secret keys in the repo or the web build. | A public web build exposes its key to anyone. Read-only sample data makes that harmless. |
| TD-13 | Work tracking: no local folders. Use GitHub Issues only if tracking is needed. Not set up yet. | Farrel's rule. Nothing to set up until he wants tickets. |

---

## 6. Assumptions and open questions

### Assumptions (used in the build, to be confirmed)
- A-1: The demo is shown on a phone or on a laptop with a phone-size window.
- A-2: Sample prices, stores, distances, vouchers, minimum order, delivery fee and free-delivery threshold are made up by us and labeled sample.
- A-3: Astro features come from Farrel's feature inventory PDF (guest-mode view of the live Astro site on 23 Nov 2026). Features behind Astro's login are described, not verified.
- A-4: Aice names and product types can be used for a private meeting demo. Not confirmed, see OQ-3.
- A-5: Flutter is not yet confirmed in this environment. B0 must confirm or install it.
- A-6: Product categories follow the brief (cones, tubs, sticks, yoghurt, drinks, bundles), not the inventory's list. See D-4.
- A-7: A Supabase project can be used or created for this demo. Not confirmed, see OQ-13.

### Open questions

| ID | Question | Owner | Blocks next milestone? |
|---|---|---|---|
| OQ-1 | Meeting date: **"no date yet"** (Farrel, 2026-11-23, said twice). How many hours can be spent? Still unanswered. Plan keeps the 2.5 to 3 day assumption. | Farrel | No for B0 to B1. Yes before B3, because it decides the cut line. |
| ~~OQ-2~~ | ~~Will Astro screenshots be uploaded?~~ **Answered 2026-11-23:** a feature inventory PDF in Drive. Plan updated. Screenshots inside it were not viewed. | Farrel | Closed |
| OQ-3 | Trademark: can Aice names, logo, product photos be shown in a private meeting? Are we the brand or a reseller? Who checks? | Farrel | No. Placeholders are confirmed for now. |
| OQ-4 | Does an "app building guidebook" exist? Where is it? It is not in the repo. | Farrel | No, but if it exists, it can change TD-4 and TD-5. |
| OQ-5 | Who will hold the demo: Farrel on his phone, or Aice people tapping on their own phones? | Farrel | No. Affects how much error handling is needed. |
| OQ-6 | What device and network will the meeting use? Flutter web can be slow on weak Wi-Fi, and Supabase adds a network call. | Farrel | No. Needed by B8. |
| OQ-7 | Vercel project and domain: use an existing Vercel account? Custom domain or the default `.vercel.app` link? | Farrel | No. Needed by B0 deploy. |
| OQ-8 | Sample store names and areas: pick real city area names (fictional stores) or generic? Which city? | Farrel | No. |
| OQ-9 | What does the real project need beyond the customer app (store app, courier app, admin)? Unknown. | Farrel and Aice | No. Needed for the long-term plan only. |
| OQ-10 | Real Aice product range and categories. Brief and inventory differ (see D-4). Real halal and BPOM numbers are not ours to invent. | Farrel and Aice | No. Demo uses sample data. |
| OQ-11 | Aice's real late-delivery and melt rules. Astro's rule (10 minutes late, fee refund; claim within 24 hours) is used only as a sample. | Farrel and Aice | No. |
| OQ-12 | Who would deliver in the real project (own riders, courier apps, partner shops) and in which cities? The inventory says this decides cost, speed and melt risk. The demo names no courier. | Farrel and Aice | No. Needed for the long-term plan. |
| OQ-13 | Supabase: use an existing project of yours, or may Claude create a new one (the free plan may be enough; a paid one costs money)? Should orders also be saved to Supabase, or stay on the device? Plan says on the device. | Farrel | **Yes** for B0b. |
| ~~OQ-14~~ | ~~Login, referral, coins, wallet: which does Farrel want?~~ **Answered 2026-11-23:** none for now. | Farrel | Closed |
| OQ-15 | Do you want tickets (GitHub Issues) at all? A ticket is one small task card, for example "build the cart screen". | Farrel | No. |

---

## 7. Risks

| ID | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R-1 | Scope too large for the time. 9 screen groups plus tests plus Supabase plus deploy. | High | High | Fixed cut order, hard freeze at B8, never-cut list. Ask OQ-1. |
| R-2 | The demo looks fine but the Aice team expects "real". Expectations unclear. | Medium | High | Label sample data in the UI. Say in the meeting what is mocked. Keep a one-page "what is real and mocked" list. |
| R-3 | Flutter web on Vercel: no Flutter in Vercel's build, slow first load on a phone. | Medium | High | Build outside Vercel and deploy the output. Test on a real phone in B0, not at the end. Open the link once before the meeting to warm it up. |
| R-4 | Trademark or partnership claim problem. | Low | High | No Aice logos or photos. Footer disclaimer. Check before any use beyond the meeting. |
| R-5 | Copying Astro too closely. The inventory itself says copy features, not the look, name, mascot or artwork. | Low | Medium | Own wording, own visuals, own colors. |
| R-6 | Meeting network is bad. | Medium | High | Keep a screen recording of the full flow as a backup. The bundled data copy keeps the app usable even if the network call fails. |
| R-7 | Tests slow the build and the deadline slips. | Medium | Medium | Test only logic and the main flow. Skip pixel tests. |
| R-8 | Small basket problem: Aice items are cheap, so a minimum order and delivery fee can look bad. The Aice team may ask about it. | Medium | Medium | Demo shows multi-buy discount, bundles and free delivery over a threshold. The numbers are sample, so say so. Real numbers need Aice order value data. |
| R-9 | **Supabase fails during the demo.** Causes: bad network, wrong or expired key, a row security rule that blocks reads, a free project that was paused for being idle, or a slow first call. Result without a fallback: an empty home screen in front of Aice. | Medium | High | (1) Fallback: if a Supabase call fails or takes longer than about 3 seconds, the app uses the bundled copy and shows no error. (2) Select-only row security, tested from the public key before every deploy. (3) Open the demo link and read from Supabase the day before and an hour before the meeting to wake a paused project. (4) Bundled copy and Supabase seed come from one source file, so they cannot drift apart. (5) Test the full flow with Supabase blocked in B8. |
| R-10 | Public web build shows the Supabase key to anyone. | Medium | Low | Publishable key only, read-only rules, sample data only, no secrets in the repo. |

---

## 8. Decision log

| Date | Decision | Reason | Who decided |
|---|---|---|---|
| 2026-11-23 | Project is a clickable demo, all mocked, for an Aice meeting. | Stated in the brief. | Farrel |
| 2026-11-23 | Only Aice products and a few Aice stores shown. Brand and Store kept as separate data models. | Stated in the brief. | Farrel |
| 2026-11-23 | Stack: Flutter with web build on Vercel. | Stated in the brief. | Farrel |
| 2026-11-23 | Use TDD. | Stated in the brief. | Farrel |
| 2026-11-23 | UI in Indonesian. | Stated in the brief. | Farrel |
| 2026-11-23 | Sprint mode chosen. | Demo with a near deadline. | Claude (proposal) |
| 2026-11-23 | Meeting date: "no date yet". Plan keeps the 2 to 3 day assumption (now 2.5 to 3 with Supabase). | Farrel's answer to OQ-1. | Farrel |
| 2026-11-23 | Astro feature source is Farrel's inventory PDF. The copy list in section 2 comes from it. | Farrel supplied it in place of screenshots. | Farrel (source), Claude (list) |
| 2026-11-23 | Multi-buy discount is real, tested logic. Guarantee renamed "Garansi Tidak Meleleh". **Pending confirmation.** | Inventory calls multi-buy the main basket builder and melt the top worry for ice cream. | Claude (proposal) |
| 2026-11-23 | Mix pack builder is an optional extra, only after B6. **Pending confirmation.** | Not in the brief. Targets the small basket problem. | Claude (proposal) |
| 2026-11-23 | **Use Supabase** for sample data (replaces "local mock data", TD-2). | Farrel's decision. | Farrel |
| 2026-11-23 | Keep a bundled local copy as automatic fallback. Cart and orders stay on the device. **Pending Farrel's answer on orders (OQ-13).** | Supabase adds a real way to fail in the meeting. The copy removes it. | Claude (proposal) |
| 2026-11-23 | **Use drawn placeholders** for Aice logos and photos (TD-7). | Farrel's decision. | Farrel |
| 2026-11-23 | No local folders for tracking work. Use GitHub Issues if tickets are wanted (TD-13). | Farrel's decision. | Farrel |
| 2026-11-23 | **No login, referral, coins or wallet for now** (TD-11). Closes OQ-14. | Farrel's decision. | Farrel |

---

## 9. Discrepancies with other docs

| ID | Other doc says | Plan says | Action |
|---|---|---|---|
| D-1 | Brief: "Follow my app building guidebook if it is in the repo." | The repo is empty. No guidebook found. | Farrel to say where it is (OQ-4). Plan adopts it if found. |
| D-2 | Brief: "read any Astro screenshots I upload." Inventory PDF has screenshots with captions. | Only the PDF text was read. The images were not viewed. Cart, checkout, tracking, history, profile and address picker are not shown in Astro screenshots at all. | Our versions of those screens are our own design. Farrel can upload the images if he wants Claude to check the visuals. |
| ~~D-3~~ | ~~Brief: "Supabase or local mock data." Plan picked local.~~ | **Resolved 2026-11-23:** Farrel chose Supabase. Plan follows (TD-2). | Closed |
| D-4 | Brief categories: cones, tubs, sticks, yoghurt, drinks, bundles. Inventory suggests: stick, cone, cup, mochi, family tub, new flavors, bundles. | Plan uses the brief's 6 categories. | Farrel to say if mochi, cups or new flavors should be added (OQ-10). |
| D-5 | Brief: "simple ask AI helper like Astro's AI-RO." The inventory does not mention AI-RO. | Plan builds a scripted "Tanya AI" with no reference to how AI-RO really works. | Farrel to share AI-RO details if he wants a closer match. |
| D-6 | Brief: "late delivery guarantee." Inventory: Astro refunds the delivery fee if more than 10 minutes late, no refund when delivery was free. | Plan uses that as a sample rule, not Aice's rule. | Real rule needed from Aice (OQ-11). |
| ~~D-7~~ | ~~Inventory marks login, referral, loyalty, wallet as MVP or V2.~~ | **Resolved 2026-11-23:** Farrel decided to skip them for now. | Closed |
