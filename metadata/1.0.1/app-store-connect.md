# Black Swan — App Store Connect Metadata

**Version:** 1.0.1  
**Build:** 1  
**Locale (primary):** English (U.S.) — `en-US`  
**Last updated:** 2026-07-20

---

## App identity

| Field | Value |
|--------|--------|
| **App name** | Black Swan - Unexpected events |
| **Subtitle** | Fragility coach for surprises |
| **Bundle ID** | `giusscos.BlackSwan` |
| **Apple ID (App)** | `6745398469` |
| **SKU** | `giusscos.BlackSwan` |
| **Team ID** | `MA7MBQ947C` |
| **Primary category** | Lifestyle (`public.app-category.lifestyle`) |
| **Secondary category** | — *(optional: Productivity or Finance)* |
| **Content rights** | Does not contain third-party content |
| **Age rating** | 4+ *(review in App Store Connect questionnaire)* |

---

## Version information

| Field | Value |
|--------|--------|
| **Marketing version** | `1.0.1` |
| **Build number** | `1` |
| **Minimum iOS** | 18.4 |
| **Supported devices** | iPhone (portrait); iPad (portrait + landscape) |
| **Uses non-exempt encryption** | No (`ITSAppUsesNonExemptEncryption = NO`) |

---

## What’s New (1.0.1)

```
What's new in 1.0.1

• Fragility score — see weak spots by theme and how exposure shifts over weeks
• Weekly review — a 7-day ritual with focus, wins, and open protections
• Pre-mortems — plan buffers before the next surprise, then check them off
• Mitigation checklists — mark protections done so fragility actually falls
• Concept onboarding — learn Black Swan vs deliberate risk before you start
• Guided tips on Home for a quick tour
```

---

## Description

```
Black Swan helps you notice fragile spots in your life and reduce damage from surprises — not just label events.

Inspired by Nassim Taleb’s idea of Black Swans (rare, high-impact events that seem obvious only after they happen), the app is a fragility and decision coach: log shocks, classify them, build buffers, and review exposure over time.

HOW IT WORKS

1. Log an event — a sudden shock or a risk you chose
2. Classify it as Black Swan or Deliberate — on-device Core ML
3. Get an explanation and a mitigation plan — Apple Intelligence when available, with offline fallbacks
4. Mark protections done
5. Watch your fragility score and themes over weeks
6. Run pre-mortems before the next surprise

FEATURES

• Event journal with Black Swan vs Deliberate classification
• Confidence scores and manual override when you disagree
• Mitigation checklists you can tick off
• Fragility score and theme breakdown (money, work, health, relationships, and more)
• Weekly review ritual — focus, wins, and open actions
• Pre-mortem plans with buffer checklists
• Private on-device processing — your notes stay on your device

WHO IT’S FOR

Anyone who wants to prepare for surprise — freelancers, founders, and people who feel one shock away from fragile finances or plans. Not a generic journal. Not an AI demo. A practical habit for limiting downside.

SUBSCRIPTION

Full access requires an auto-renewable subscription (weekly or yearly). See in-app purchase details for pricing. Privacy Policy and Terms of Use are linked in the app and below.
```

---

## Promotional text

*(Up to 170 characters — can be updated without a new binary)*

```
Spot fragile spots before the next surprise. Log shocks, build buffers, and watch your fragility fall — privately on your device.
```

---

## Keywords

*(Comma-separated, max 100 characters total — no spaces after commas preferred)*

```
black swan,fragility,journal,risk,mitigation,premortem,decision,buffer,resilience,coach
```

**Character count:** 97

---

## Support & legal URLs

| Field | URL |
|--------|-----|
| **Privacy Policy** | https://giusscos.it/privacy |
| **Terms of Use (EULA)** | https://www.apple.com/legal/internet-services/itunes/dev/stdeula/ |
| **Support URL** | https://giusscos.it *(confirm or replace with dedicated support page)* |
| **Marketing URL** | — *(optional)* |

---

## In-App Purchases / Subscriptions

**Subscription group**

| Field | Value |
|--------|--------|
| **Group ID** | `21679517` |
| **Group name** | Unlock Full Access |
| **Display name (en-US)** | Unlock Black Swan Full Access |

**Products**

| Reference name | Product ID | Period | Price (USD) | Display name | Description |
|----------------|------------|--------|-------------|--------------|-------------|
| BlackSwan Yearly $19.99, 1 Week free | `bs_1999_1y_1w` | 1 year | $19.99 | Yearly Access | Full Access to the app for a year |
| Weekly | `com.giusscos.blackswan.weekly` | 1 week | $4.99 | Weekly Access | Full Access to the app for one week |

**App Store Connect notes**

- Family Sharing: off for both products (current StoreKit config)
- Introductory offer: yearly reference name mentions 1 week free — confirm offer is configured in App Store Connect
- Subscription store policy destinations in app: Privacy Policy + Apple Standard EULA

---

## App Review information

| Field | Suggested value |
|--------|-----------------|
| **Contact** | Giuseppe Cosenza |
| **Demo account** | Not required (no login) |
| **Notes for review** | See below |

### Review notes

```
Black Swan is a subscription lifestyle app. After launch, complete the short concept onboarding (or skip), then use the paywall to subscribe or Restore Purchases.

No account or login is required. All user content is stored on device (SwiftData). Classification uses on-device Core ML; optional insights use Apple Foundation Models when available.

Privacy Policy: https://giusscos.it/privacy
Terms: Apple Standard EULA
```

---

## Privacy (App Privacy labels)

Confirm in App Store Connect. Based on current product behavior:

| Data type | Collected? | Linked to identity? | Used for tracking? | Notes |
|-----------|------------|---------------------|--------------------|-------|
| **Purchases** | Yes | No | No | StoreKit subscription status |
| **User content** (journal text) | Processed on device | No | No | Not sent to developer servers for classification |
| **Diagnostics** | Optional / none configured | — | — | Confirm if Crash reports enabled |
| **Contact info / Location / Health** | No | — | — | — |

**Privacy nutrition label summary (draft):** Data Not Collected for identity; Purchases may be disclosed as App Store purchase history as required. Re-verify against App Store Connect questionnaire before submit.

---

## Capabilities & entitlements (for ASC / binary consistency)

| Capability | Status |
|------------|--------|
| **App Sandbox** | Yes |
| **Push Notifications** (`aps-environment`) | Entitlement present (development); `remote-notification` background mode in Info.plist — **not fully wired in product** |
| **iCloud / CloudKit** | Container `iCloud.giusscos.BlackSwan` — **entitlement present; sync not productized** |
| **In-App Purchase** | Yes (StoreKit 2) |

---

## Localization checklist

| Locale | Name | Subtitle | Description | Keywords | What’s New | Screenshots |
|--------|------|----------|-------------|----------|------------|-------------|
| en-US | Black Swan | Fragility coach for surprises | ✓ (above) | ✓ | ✓ | Required |
| Other | — | — | — | — | — | Optional |

---

## Screenshots

**Devices:** capture for required iPhone sizes (6.9" primary); repeat same frames for other sizes. iPad optional but recommended if listed as supported.  
**Style:** one device frame per shot; short headline + optional subline overlaid above/below UI; no clutter; show real product UI with sample events filled in.

### Set order (en-US) — 6 frames

| # | Screen to capture | Headline | Subline |
|---|-------------------|----------|---------|
| 1 | **Home** — event carousel + fragility banner | Prepare for surprise | Log shocks. Spot fragile spots. Limit the damage. |
| 2 | **Event details** — Black Swan label, confidence, explanation | Black Swan or deliberate? | On-device classification with confidence you can override. |
| 3 | **Event details / card** — mitigation checklist partially done | Turn insight into protection | Check off buffers so fragility actually falls. |
| 4 | **Fragility (Insights)** — score + theme breakdown | See where you’re exposed | A fragility score and themes across money, work, health, and more. |
| 5 | **Weekly review** — headline, focus, wins | Make it a weekly ritual | Seven days of shocks, wins, and one clear focus ahead. |
| 6 | **Pre-mortem** — scenario + buffer checklist | Plan before the hit | Run a pre-mortem and build buffers while you still can. |

### Optional frames (7–10)

| # | Screen to capture | Headline | Subline |
|---|-------------------|----------|---------|
| 7 | **Concept onboarding** — “What is a Black Swan?” | Know the difference | Unexpected shocks vs risks you chose on purpose. |
| 8 | **Home empty / add event** | Capture the shock while it’s fresh | Write what happened — we’ll classify and suggest protections. |
| 9 | **Paywall** *(only if honest about subscription)* | Full access when you’re ready | Weekly or yearly — cancel anytime in Settings. |
| 10 | **Privacy / on-device cue** — Home disclaimer or insights | Private by design | Classification and notes stay on your device. |

### Overlay copy blocks (ready to paste into design)

**1 — Home**
```
Prepare for surprise
Log shocks. Spot fragile spots. Limit the damage.
```

**2 — Classification**
```
Black Swan or deliberate?
On-device classification with confidence you can override.
```

**3 — Mitigations**
```
Turn insight into protection
Check off buffers so fragility actually falls.
```

**4 — Fragility**
```
See where you’re exposed
A fragility score and themes across money, work, health, and more.
```

**5 — Weekly review**
```
Make it a weekly ritual
Seven days of shocks, wins, and one clear focus ahead.
```

**6 — Pre-mortem**
```
Plan before the hit
Run a pre-mortem and build buffers while you still can.
```

**7 — Onboarding (optional)**
```
Know the difference
Unexpected shocks vs risks you chose on purpose.
```

**8 — Add event (optional)**
```
Capture the shock while it’s fresh
Write what happened — we’ll classify and suggest protections.
```

**9 — Paywall (optional)**
```
Full access when you’re ready
Weekly or yearly — cancel anytime in Settings.
```

**10 — Privacy (optional)**
```
Private by design
Classification and notes stay on your device.
```

### Capture notes

- Prefill with believable sample events (money / work / health) so cards look alive — use in-app mock data if available in a debug build.
- Prefer light system appearance unless dark is the default brand look; keep all shots in the same appearance.
- Hide debug-only controls (e.g. “Add mock data”) before capture for App Store builds.
- Keep overlay text ≤ ~2 lines; headline punchy, subline explanatory.
- Do not claim “AI predicts Black Swans” — position as classification, buffers, and fragility coaching.
- First three screenshots matter most in search results: Home → Classification → Mitigations (or Fragility).

### App Preview (optional)

| Beat | Length | On-screen copy |
|------|--------|----------------|
| Open Home with events | ~3s | Prepare for surprise |
| Open event → show label + checklist | ~5s | Black Swan or deliberate? |
| Fragility score | ~4s | See where you’re exposed |
| Weekly review or Pre-mortem | ~5s | Make it a weekly ritual |
| End on Home / icon | ~2s | Black Swan |

Suggested total: **15–30 seconds**.

---

## Assets checklist

| Asset | Requirement | Status |
|--------|-------------|--------|
| App icon | 1024×1024 | In Xcode asset catalog |
| iPhone 6.9" screenshots | Required for submission | Use frames 1–6 (+ optional) |
| iPhone 6.5" / 6.3" | As required by ASC | Same copy set, resized |
| iPad screenshots | If iPad supported | Same narrative, landscape/portrait as needed |
| App Preview video | Optional | Script above |

---

## Version history notes

### 1.0.1 (this release)

- Fragility score, weekly review, pre-mortems, mitigation checklists
- Concept onboarding separate from paywall
- What’s New sheet + TipKit guided steps on Home
- Subscriptions: yearly `bs_1999_1y_1w`, weekly `com.giusscos.blackswan.weekly`

### 1.0 (baseline)

- Event CRUD, Core ML classifier, StoreKit subscriptions
