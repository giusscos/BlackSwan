# Black Swan 1.0.2 — App Store Connect release kit

**Version:** 1.0.2 (`MARKETING_VERSION` already bumped)
**Locale:** English (U.S.)
**Prepared:** 2026-10-16

Copy each block into the matching App Store Connect field. Lengths were checked against Apple's limits (counts in brackets).

---

## Why this listing changes

Numbers from App Store Connect (App Analytics, pulled 2026-10-16):

| Metric | Last 90 days | Lifetime (May 2025 – Oct 2026) |
|---|---|---|
| Impressions | 975 (≈11/day) | — |
| Product page views | 41 | — |
| First-time downloads | 4 | 36 (≈20 in launch week) |
| Impression → download | 0.5% | — |
| Proceeds / paying users | none | none |

What that says:

1. **Almost nobody finds the app.** About 11 impressions a day means the app barely ranks for any search. Most of the listing's search weight sits in the name and subtitle, and today they say "Unexpected events" and "Fragility coach for surprises". Nobody searches for either.
2. **People who see it don't tap through.** About 4% of impressions open the page. The first three screenshots show in search results, and today they're pale grey UI with small text.
3. **No one has ever paid.** The paywall promised "start with a free trial", but the Yearly plan has **no introductory offer** in App Store Connect. The reference name says "1 Week free", but the synced StoreKit file and the live sandbox products both show no trial. The new paywall shows the trial only when the offer really exists, so set it up (see "Subscriptions" below).

---

## App Name *(30)* — changes with the new version

```
Black Swan: Life Risk Planner
```
[29] Keeps the brand and adds "risk" and "planner", which people do search for.

## Subtitle *(30)*

```
Be ready for the next shock
```
[27] Outcome-first, matches the paywall headline. Alternative to A/B later with Product Page Optimization: `Emergency plan for life shocks` [30].

## Promotional Text *(170, can change without a new build)*

While the free trial is live:
```
A lost client, a surprise bill, a market drop. Log the shock, get a plan, and watch your fragility fall. Private, on your device. Try it free for 1 week.
```
[153]

If the trial isn't set up:
```
A lost client, a surprise bill, a market drop. Log the shock, get a plan, and watch your fragility fall. Private, on your device, no account needed.
```
[148]

## Keywords *(100)*

```
emergency,fund,crisis,worry,journal,resilience,premortem,fragility,backup,stress,money,job,loss,plan
```
[100] No words repeated from the name or subtitle: Apple already indexes those, so repeating them wastes characters. Single words combine across fields ("emergency" + "fund", "job" + "loss", "risk" + "planner").

## Description *(4000)*

```
Life doesn't send a warning. A client cancels, a hospital bill lands, the market drops overnight. You can't predict the next shock, but you can be ready for it.

Black Swan helps you spot where you're fragile and protect yourself before the next surprise hits.

TURN A SHOCK INTO A PLAN
Write what happened in a sentence. Black Swan tells you whether it was a true Black Swan (rare, severe, unexpected) or a deliberate risk you chose, with a confidence score you can override. Then it suggests concrete protections you can tick off.

WATCH YOUR FRAGILITY FALL
Every protection you finish lowers your fragility score. See which areas of life are most exposed, from money and work to health and relationships, and how that changes week by week.

A FIVE-MINUTE WEEKLY REVIEW
Look back at the week's shocks, celebrate the wins, and pick one focus for the week ahead.

PRE-MORTEMS
Imagine the worst case before it happens: lose your main income for 90 days, a health scare, a forced move. Black Swan helps you write the scenario and the buffers that would soften it.

PRIVATE BY DESIGN
No account and no tracking. Classification runs on your device with Core ML, and insights use Apple Intelligence on supported devices. Your notes stay on your iPhone.

Inspired by Nassim Taleb's idea of Black Swans: rare, high-impact events that only seem obvious afterwards. Not a generic journal. A practical habit for limiting the downside.

BLACK SWAN SUBSCRIPTION
Full access requires a subscription, billed weekly or yearly. New subscribers to the yearly plan may be eligible for a free trial. Payment is charged to your Apple Account. Subscriptions renew automatically unless cancelled at least 24 hours before the end of the current period. Manage or cancel anytime in your Apple Account settings.

Terms of Use: https://www.apple.com/legal/internet-services/itunes/dev/stdeula/
Privacy Policy: https://giusscos.it/privacy
```

> Fixes in the current live description: it says "weekly or yearly" in one place and "monthly or yearly" in another. Monthly is removed from sale, so the text now only says weekly or yearly.

## What's New in This Version *(4000)*

```
• A new welcome tour: tell us what feels fragile and see Black Swan turn a real shock into a plan in seconds
• A clearer subscription screen that shows exactly what you pay and when
• Free-trial reminder: get a notification 2 days before your trial ends
• New subscribers go straight to logging their first event
• Small fixes and polish
```

---

## Screenshots (ByJo style, same layout as pola's 1.0.6 "B" set)

Slides are in `metadata/1.0.2/byjo/<device>/<language>/NN-<screen>.png`, numbered in upload order:
- `iphone`: 1290 × 2796 (6.9"; App Store Connect scales it down for smaller iPhones)
- `ipad`: 2064 × 2752 (13")

Layout: `#EBEBEB` background, SF Compact Rounded Bold title in the icon's red, Semibold subtitle, one device running off the bottom. Captions are in each language file under **Screenshot captions (ByJo style)**; `metadata/check_lengths.py` keeps them to one line.

| # | Screen | Shows |
|---|---|---|
| 1 | `home` | Event carousel + fragility banner |
| 2 | `detail` | Black Swan label, confidence, explanation, checklist |
| 3 | `fragility` | Score, theme breakdown, recent weeks |
| 4 | `review` | Weekly review with the on-device summary |
| 5 | `premortem` | Saved pre-mortem with buffers |
| 6 | `demo` | Onboarding demo: a shock turning into a plan |

**Rebuilding:**
```bash
xcodebuild -project BlackSwan.xcodeproj -scheme BlackSwan -configuration Debug -destination 'generic/platform=iOS Simulator' -derivedDataPath build/dd build
metadata/1.0.2/capture.sh build/dd/Build/Products/Debug-iphonesimulator/BlackSwan.app
python3 metadata/1.0.2/make_byjo.py
```
`capture.sh` launches Debug builds with `-ScreenshotScreen <screen>` (see `ScreenshotHarness.swift`, compiled out of Release), which reseeds sample data in the current language and opens that screen directly. `ONLY=ipad` or `ONLY=iphone` re-runs one device.

## Subscriptions

> Done 2026-10-16: the 1-week free intro offer on Yearly is live (Upfront, 175 countries, no end date), and Billing Grace Period is on (16 days, all renewals, production + sandbox). Version 1.0.2 is created with the name, subtitle, promotional text, description, keywords, What's New and review notes below. German, Spanish (Spain), French and Italian localizations are added with name, subtitle, promotional text, description, keywords and What's New. Still to do: upload the screenshots and a 1.0.2 build.

| Product | ID | Price | Status | To do |
|---|---|---|---|---|
| Yearly | `bs_1999_1y_1w` | $19.99 | Approved | **Add an introductory offer: Free, 1 week, all countries.** Then re-sync `storekitSubs.storekit` in Xcode (Editor → Sync). |
| Weekly | `com.giusscos.blackswan.weekly` | $4.99 | Approved | Nothing. It anchors the yearly plan ("Save 92%"). |
| Monthly | `bs_199_1m_3d` | $1.99 | Removed from sale | Leave it off. |

Also worth turning on:
- **Billing Grace Period** (Subscriptions → Set Up Billing Grace Period). Today it's off, so a failed card cuts access immediately.
- **Subscription image** (1024×1024, optional). It's needed for win-back offers later.

---

## App Review notes

```
Black Swan is a subscription app. On first launch there is a 4-screen welcome tour (or tap Skip), then the subscription screen with both plans, Restore Purchases, Terms of Use and Privacy Policy links. The price and renewal terms are shown under the purchase button.

If a free trial is active, the app can schedule one local notification 2 days before the trial ends. It asks for notification permission only after a purchase, and only if the "Remind me" toggle is on.

No account or login is required. All content is stored on device (SwiftData). Classification uses on-device Core ML; optional insights use Apple Foundation Models when available.
```

> In App Review → Sign-In Information, make sure **"Sign-in required"** is unticked. The app has no login.

---

## Category

Keep **Lifestyle** as the primary category and set **Productivity** as the secondary. Lifestyle is crowded; Productivity adds a second chart to show up in.
