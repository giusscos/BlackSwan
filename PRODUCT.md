# Black Swan — Product Direction & Change Log

Living document for product intent, architecture choices, and shipped changes.

---

## Product vision

**Job to be done:** Help people notice fragile spots in their life/finances and reduce damage from surprises — not just label events.

**Core loop**

1. Log an event (shock or chosen risk)
2. Classify as **Black Swan** vs **Deliberate** (on-device Core ML)
3. Get explanation + mitigation plan (Foundation Models when available)
4. Mark protections done
5. Review fragility over time (themes, score, weekly ritual)
6. Run **pre-mortems** before the next surprise

**Positioning**

- Not a generic journal
- Not an “AI demo”
- A **fragility / decision coach** with a Taleb-inspired framing

**Monetization**

- Subscription gate after concept onboarding
- Products: monthly `bs_199_1m_3d`, yearly `bs_1999_1y_1w` (group `21679517`)

---

## Platform & stack

| Layer | Choice |
|--------|--------|
| UI | SwiftUI |
| Persistence | SwiftData (`Swan`, `PreMortem`) |
| Classification | Core ML `BlackSwanV250000Finance` + `NLModel` confidence |
| Insights / copy | Apple Foundation Models (iOS 26 + Apple Intelligence), with offline fallbacks |
| Payments | StoreKit 2 + `SubscriptionStoreView` + `subscriptionStatusTask` |
| Min OS (current) | iOS 18.4 (app already uses iOS 26 APIs where available) |

**Open question:** Raise deployment target to **iOS 26-only** for simpler Apple Intelligence UX, while **keeping** the trained Core ML classifier (hybrid pipeline). Do **not** drop Core ML for Foundation-Model-only classification.

---

## Information architecture

```
Launch
  ├─ Concept onboarding (what is a Black Swan, vs deliberate, buffers, how app helps)
  ├─ Paywall (if not subscribed)
  └─ Home
       ├─ Event carousel (filter / sort)
       ├─ Fragility banner → Insights
       ├─ Weekly review
       ├─ Pre-mortem
       ├─ Add / edit event → classify + insight
       └─ Event details → override, checklist, refresh insight
```

---

## Domain model (current)

### `Swan` (logged event)
- Text, timestamp
- `classification`: blackSwan | deliberate
- `probability` (0…100)
- `theme`: money | work | health | relationships | other
- `explanation`
- `mitigationItems` (JSON checklist with done state)
- `isManualOverride`

### `PreMortem`
- Worry prompt, scenario, theme
- `bufferItems` (checklist)

### Analytics
- `FragilityAnalytics` → score /100, theme stats, week buckets, open vs completed actions

---

## AI pipeline

```
User text
  → ClassificationService (Core ML label + NLModel confidence)
  → map noBlackSwan → deliberate
  → InsightService (Foundation Model or offline defaults)
       → explanation, mitigations, theme
  → persist + show confidence / checklist
```

Fallbacks exist so the app remains useful without Apple Intelligence.

---

## Direction — keep / build / avoid

### Keep
- Hybrid Core ML + Foundation Models
- Confidence + manual override (trust)
- Mitigations as the habit, not the label
- Narrow educational onboarding (concept before paywall)

### Build next (suggested)
- [ ] Notifications for weekly review
- [ ] Stronger domain wedge (e.g. finance/freelance-only) in copy + training data
- [ ] Use overrides to improve/retrain the classifier
- [ ] iCloud sync (entitlement exists; not wired) **or** remove unused CloudKit/push
- [ ] Decide iOS 26 deployment floor
- [ ] Gate or remove “Add mock data” for App Store builds (`#if DEBUG`)

### Avoid
- Theme/cosmetic churn as the product
- LLM-only classification without evaluation
- Feature sprawl before the weekly ritual feels sticky

---

## Change log

### 2026-10-16 — Onboarding, paywall and listing for 1.0.2

**Why:** App Analytics showed 975 impressions, 41 page views and 4 downloads in 90 days, and no paid conversions ever. The paywall promised a free trial that isn't configured in App Store Connect.

**Product**
- Onboarding rewritten in pola's style: hook → "what feels fragile?" (money / work / health / relationships) → live demo of a shock turning into a plan → fragility score falling → paywall
- Custom paywall replaces `SubscriptionStoreView`: headline personalized to the chosen theme, plans pinned with the CTA, "Save 92%" and per-week price, charge disclosure under the button, trial timeline and trial-ending reminder only when the intro offer is really redeemable
- After purchase: "You're all set" screen → straight into logging the first event (skips What's New)
- "Add mock data" is Debug-only

**Technical**
- `Store`: `purchase`, `restorePurchases`, `trialEligibleIDs`, price helpers on `Product`; Debug flags `SimulatorSubscribed` / `SeedScreenshotData` for screenshots
- `FocusThemes` (`@AppStorage("focusThemes")`), `TrialReminder` (local notification 2 days before the trial ends)
- `WhatsNewView.contentVersion` so the sheet only re-shows when its content changes
- Listing, metadata and screenshots in `metadata/1.0.2/`

**Localization (same release)**
- App in German, Spanish, French and Italian: `Localizable.xcstrings` (266 strings), filled by `metadata/localization/apply_translations.py` from `translations.py`
- Model strings (labels, themes, fallback insights, summaries, sample data) use `String(localized:)`; plural hacks rewritten as "Label: count"
- Foundation Models are told to answer in the device language; theme keys stay English
- Theme inference keywords cover all five languages. The Core ML classifier is still English-trained, so non-English events may classify less reliably
- App Store: localized name, subtitle, description, keywords, promo text and What's New for de, es-ES, fr-FR, it
- `ScreenshotHarness` (Debug only, `-ScreenshotScreen <name>`) + `metadata/1.0.2/capture.sh` + `make_byjo.py` produce ByJo-style slides for iPhone and iPad in every language

### 2026-07-20 — What’s New + TipKit guided steps

**Product**
- What’s New sheet on Home after version updates (also via Menu → What’s New)
- TipKit ordered tips: Add event → Fragility → Weekly review → Pre-mortem

**Technical**
- `WhatsNewView` + `AppVersion`; `@AppStorage("lastSeenWhatsNewVersion")`
- `AppTips` TipKit tips; `Tips.configure` in `BlackSwanApp`; `TipGroup(.ordered)` on Home

### 2026-07-20 — Value loop + paywall unlock + docs

**Product**
- Concept onboarding (4 pages) separate from paywall; removed obsolete “themes” promise
- Fragility score, theme breakdown, multi-week chart (`InsightsView`)
- Weekly review (7-day summary, focus, wins, open actions)
- Pre-mortem generator + saved plans with buffer checklists
- Mitigation mark-as-done on details and cards
- Risk themes on events
- Home toolbar: Fragility, Review, Pre-mortem, **Add mock data**
- Sample data seeder (`MockData`) for demos

**Technical**
- `ClassificationService` — cached model, label mapping (`noBlackSwan` → deliberate), confidence via `NLModel`
- `InsightService` — insights, pre-mortems, weekly review (+ offline defaults)
- `Store` — `isSubscribed` via `Product.SubscriptionInfo.status` + entitlements; shared via environment
- Paywall unlock: `subscriptionStatusTask` + `onInAppPurchaseCompletion` → immediate navigate to Home
- SwiftData schema: `PreMortem`; mitigations stored as JSON checklist

**Earlier same session (foundation)**
- Fixed silent ML label mismatch and unused probability
- Split education vs subscription paywall
- Foundation Model explanations wired on save
- Confidence badges, delete confirmation, shared Store

### Pre-2026-07-20 (baseline v1.0)

- SwiftUI event CRUD + horizontal card UI
- Core ML text classifier (`BlackSwanV250000Finance`)
- StoreKit subscriptions
- Themes / color customization later removed (“liquid glass” direction)
- CloudKit / push entitlements present but unused

---

## How to demo

1. Complete concept onboarding (or skip)
2. Subscribe / restore (StoreKit config in Debug)
3. Menu → **Add mock data**
4. Swipe events, open details, check off mitigations
5. Open **Fragility** and **Weekly review**
6. Run a **Pre-mortem** from the menu

---

## Notes for future contributors

- Subscription group ID: `21679517`
- Privacy: `https://giusscos.it/privacy`
- Classifier class labels in model: `blackSwan`, `noBlackSwan` (never map with raw `SwanClassification(rawValue:)` alone)
- Prefer extending `InsightService` / `FragilityAnalytics` over putting AI logic in views
