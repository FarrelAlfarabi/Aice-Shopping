# Master plan: Aice quick commerce demo

**Version:** 0.1 (sprint mode)
**Last updated:** 2026-11-23
**Owner:** Farrel
**Status:** Plan only. No code written. Repo was empty. No guidebook and no Astro screenshots found in the repo.

> This is a clickable DEMO. Nothing in it is a working system. Every feature below is mocked unless this plan says otherwise. It is not official Aice software and there is no partnership.

---

## 1. Goals

**Near-term goal (the milestone this plan serves):**
Show the Aice team one smooth path on a phone, from a link: pick address and store, browse, add to cart, check out with fake payment, watch the order tracking, report a melted item. It must feel as fast and clean as Astro.

**Long-term goal:**
Aice signs the real project. Later versions add other brands and real integrations.

**Success metrics:**
- The full happy path runs start to finish on a real phone with no crash, no dead button. Target: yes/no, checked by a script and by hand.
- Demo link opens on iPhone Safari and Android Chrome. Target: yes/no.
- Time from tapping the link to first screen. Target: **baseline unknown**, see OQ-6.
- Aice signs the real project. Target: **baseline unknown**, outside our control, see OQ-1.

No other targets are set. None are invented.

---

## 2. Scope

### Real now (actually works)
- Screen navigation and all the clicking.
- Cart maths: totals, voucher discount, delivery fee, free delivery over a threshold.
- Search over the local sample catalog.
- Tests (TDD) for the cart maths, voucher rules, fee rules, order status steps, search, and the scripted AI answers.
- Web build on a public link.

### Mocked (looks real, is not)
- Products, prices, photos: **sample data**, labeled "Contoh" in the UI.
- Stores, addresses, distances, open hours: **fictional sample stores**, not real Aice outlets.
- Address picker: a fixed list plus a typed text box. No real map, no GPS.
- Payments (e-wallet, bank transfer, QRIS): fake screens. No money moves.
- Order tracking and ETA countdown: a timer that fakes the steps.
- "Ask AI" helper: scripted answers. No AI model.
- Late delivery guarantee and report a problem: the flow ends in a confirmation screen. No refund happens.
- Login, profile, notifications, order history: fixed sample data on the device.
- No real customers, no real data, no backend (see decision TD-2).

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

### Later phases (not built now)
- Phase 2: real Aice catalog, real stores, real images (needs Aice and trademark clearance).
- Phase 3: backend, real login, real payment gateway, real order flow to stores.
- Phase 4: other brands. Brand and Store are separate data concepts from day one, but only Aice is shown.

### Out of scope, always for the demo
Real payment, real customer data, claiming a partnership, claiming official Aice software.

---

## 3. Users and roles
- **Customer** (the only role built). Browses, orders, tracks, reports problems.
- **Meeting audience**: the Aice team. They watch Farrel use it, or tap it themselves.
- Store staff, admin, courier, brand owner: **not built.** Later phases. Roles unknown, see OQ-9.

---

## 4. Milestones (sprint mode)

**Deadline: unknown.** See OQ-1. The blocks below assume about **2 to 3 focused working days**. If the real time is shorter, cut using the cut order.

Each block is test first: write the failing test, make it pass, then build the screen.

| Block | Work | Done when |
|---|---|---|
| B0 (1h) | Confirm Astro features list. Set up Flutter project, theme, Indonesian text, test setup, Vercel deploy of an empty app. | Empty app opens on a phone from a Vercel link. |
| B1 (2h) | Data models: Brand, Store, Product, Variant, Cart, Order. Sample data. Tests for cart maths, voucher, fee, threshold. | Logic tests pass. |
| B2 (3h) | Onboarding + Home + Product page. | Can reach a product from the first screen. |
| B3 (3h) | Cart + time slot + checkout with 3 fake payments. | Can place a fake order. |
| B4 (3h) | Order tracking, ETA countdown, frozen message. | Tracking runs after checkout. |
| B5 (2h) | Search + scripted "Tanya AI". | 10 or so scripted questions answer well. |
| B6 (2h) | Late delivery guarantee + report a problem flow. | Flow ends on a confirmation screen. |
| B7 (2h) | History, saved addresses, profile, notifications. | All reachable, all sample data. |
| B8 (2h) | Polish, phone test, speed check, rehearsal, demo script. | Full run twice with no fault. |

**Hard feature freeze:** start of B8. After that, only bug fixes. No new screens.

**Cut order (cut from the top first):**
1. Notifications screen
2. Saved addresses management (keep a fixed list)
3. Profile screen
4. "Tanya AI" helper (keep plain search)
5. Order history (keep a single sample past order)
6. Bank transfer and QRIS screens (keep e-wallet only)

**Never cut:** onboarding, home, product, cart, checkout, order tracking, report a problem. These are the story the meeting needs.

---

## 5. Tech decisions

| ID | Decision | Trade-off |
|---|---|---|
| TD-1 | Flutter, mobile first, web build. | One code base and the phone-app feel. Web load is heavier than plain HTML. |
| TD-2 | **Local mock data. No Supabase for now.** | Faster and nothing can break in the meeting. No shared data. Add Supabase only when a real backend is needed. |
| TD-3 | Brand and Store are separate models. Only Aice shown. | A bit more code now. Saves a rewrite later. |
| TD-4 | State: Riverpod or plain Provider. Pick one in B0 and stay. | Small choice, do not debate it. |
| TD-5 | TDD for logic (cart, voucher, fee, status steps, search, AI script). Widget tests for the main flow. | Slower start. Fewer bugs in the meeting. Pixel looks are checked by hand, not by tests. |
| TD-6 | Deploy the built web output to Vercel (build in CI or locally, then deploy). | Vercel's own build step does not have Flutter by default. Needs one extra setup step. See R-3. |
| TD-7 | Product pictures: simple drawn placeholders, no real Aice photos or logos. | Looks less real. Avoids trademark trouble. See OQ-3. |
| TD-8 | Colors: Aice-like blue and white, as a theme. Exact brand colors unconfirmed. | Close enough for a demo. Not an exact match. |
| TD-9 | UI language: Indonesian. This plan: English. | Code and docs stay plain English. |
| TD-10 | Footer text in the app: "Demo konsep. Bukan aplikasi resmi Aice." | Slightly less polished. Protects against a partnership claim. |

---

## 6. Assumptions and open questions

### Assumptions (used in the build, to be confirmed)
- A-1: The demo is shown on a phone or on a laptop with a phone-size window.
- A-2: Sample prices, stores, distances, vouchers and delivery threshold are made up by us and labeled sample.
- A-3: Astro features are copied from public knowledge of the app, until screenshots arrive.
- A-4: Aice names and product types can be used for a private meeting demo. Not confirmed, see OQ-3.
- A-5: Flutter is not yet installed in this environment. B0 must confirm or install it.

### Open questions

| ID | Question | Owner | Blocks next milestone? |
|---|---|---|---|
| OQ-1 | What is the meeting date and how many hours can be spent? | Farrel | **Yes.** Decides which cut list applies. |
| OQ-2 | Will Astro screenshots be uploaded? Which flows matter most? | Farrel | **Yes** for the Astro feature list. Not for B0 and B1. |
| OQ-3 | Trademark: can Aice names, logo, product photos be shown in a private meeting? Who checks? | Farrel | No. Plan uses drawn placeholders until answered. |
| OQ-4 | Does an "app building guidebook" exist? Where is it? It is not in the repo. | Farrel | No, but if it exists, it can change TD-4 and TD-5. |
| OQ-5 | Who will hold the demo: Farrel on his phone, or Aice people tapping on their own phones? | Farrel | No. Affects how much error handling is needed. |
| OQ-6 | What device and network will the meeting use? Flutter web can be slow on weak Wi-Fi. | Farrel | No. Needed by B8. |
| OQ-7 | Vercel project and domain: use an existing Vercel account? Custom domain or the default `.vercel.app` link? | Farrel | No. Needed by B0 deploy. |
| OQ-8 | Sample store names and areas: pick real city area names (fictional stores) or generic? | Farrel | No. |
| OQ-9 | What does the real project need beyond the customer app (store app, courier app, admin)? Unknown. | Farrel and Aice | No. Needed for the long-term plan only. |

---

## 7. Risks

| ID | Risk | Likelihood | Impact | Mitigation |
|---|---|---|---|---|
| R-1 | Scope too large for the time. 9 screen groups plus tests plus deploy. | High | High | Fixed cut order, hard freeze at B8, never-cut list. Ask OQ-1 first. |
| R-2 | The demo looks fine in the plan but the Aice team expects "real". Expectations unclear. | Medium | High | Label sample data in the UI. Say in the meeting what is mocked. Keep a one-page "what is real and mocked" list. |
| R-3 | Flutter web on Vercel: no Flutter in Vercel's build, slow first load on a phone. | Medium | High | Build outside Vercel and deploy the output. Test on a real phone in B0, not at the end. Open the link once before the meeting to warm it up. |
| R-4 | Trademark or partnership claim problem. | Low | High | No Aice logos or photos. Footer disclaimer. Check before any use beyond the meeting. |
| R-5 | Copying Astro too closely. | Low | Medium | Copy the flow and features, not their branding, text, or images. |
| R-6 | Meeting network is bad. | Medium | High | Keep a screen recording of the full flow as a backup. |
| R-7 | Tests slow the build and the deadline slips. | Medium | Medium | Test only logic and the main flow. Skip pixel tests. |

---

## 8. Decision log

| Date | Decision | Reason | Who decided |
|---|---|---|---|
| 2026-11-23 | Project is a clickable demo, all mocked, for an Aice meeting. | Stated in the brief. | Farrel |
| 2026-11-23 | Only Aice products and a few Aice stores shown. Brand and Store kept as separate data models. | Stated in the brief. | Farrel |
| 2026-11-23 | Stack: Flutter with web build on Vercel. | Stated in the brief. | Farrel |
| 2026-11-23 | Use TDD. | Stated in the brief. | Farrel |
| 2026-11-23 | UI in Indonesian. | Stated in the brief. | Farrel |
| 2026-11-23 | Local mock data, no Supabase (TD-2). Proposed by Claude, **pending Farrel's confirmation**. Brief said "Supabase or local". | Nothing needs a shared database. One less thing to break in a meeting. | Claude (proposal) |
| 2026-11-23 | Drawn placeholder images, no Aice logos or photos (TD-7). Proposed by Claude, **pending confirmation**. | Trademark not checked yet. | Claude (proposal) |
| 2026-11-23 | Sprint mode chosen. | Demo with a near deadline. Date still unknown (OQ-1). | Claude (proposal) |

---

## 9. Discrepancies with other docs

| ID | Other doc says | Plan says | Action |
|---|---|---|---|
| D-1 | Brief: "Follow my app building guidebook if it is in the repo." | The repo is empty. No guidebook found. | Farrel to say where it is (OQ-4). Plan will adopt it if found. |
| D-2 | Brief: "read any Astro screenshots I upload." | No screenshots found in the repo or uploads. | Farrel to upload (OQ-2). Until then, Astro features are listed from general knowledge (A-3). |
| D-3 | Brief: "Supabase or local mock data." | Plan picks local mock data. | Farrel to confirm or override. |
