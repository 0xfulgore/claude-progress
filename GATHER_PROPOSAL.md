# Gather — Proposal & Scope of Work

**Prepared by:** Gary Shannon
**Date:** 9 July 2026
**Engagement model:** Solo build, AI-augmented (Claude Code), agentic delivery
**Day rate:** AUD $1,000 / day

---

## 1. Executive summary

**Gather** is a premium, invitation-only curated dining membership club delivered as a native mobile app. Members receive **one curated dinner invitation a week** — a table of six compatible people at a vetted venue — with the whole experience engineered end-to-end: onboarding by request, compatibility-based matching, a refundable deposit that guarantees real seats, a live table thread before and after the night, and a continuity layer that turns one dinner into a lasting "crew."

The product is deliberately not a feed and not a swiping app. Its differentiators are **curation, accountability (the refundable deposit), honest transparent pricing, and continuity** — the last being described in your own deck as "the moat."

This document translates the Gather design system and product deck into a concrete, buildable scope, sets out every material technical and product decision, and gives an honest, agentic-paced timeline with iteration buffer built in.

**Bottom line for a launch-ready MVP in one city:**

| Estimate | Working days | Cost @ $1k/day | Calendar (5 days/wk) |
|---|---|---|---|
| Focused / agentic pace | ~50 days | **$50,000** | ~10 weeks |
| **Recommended planning number** | **~65 days** | **$65,000** | **~13 weeks (~3 months)** |
| Conservative (max buffer) | ~74 days | $74,000 | ~15 weeks |

For context, a traditional agency would typically quote **$150k–$300k+ and 6–9 months** for a payments-and-realtime-heavy, two-sided mobile product plus its operations tooling. The agentic solo model compresses the *build* dramatically; it does not compress payment edge-cases, app-store review, real-device QA, or your review-and-iteration cycles — which is exactly where the buffer below is spent.

---

## 2. What we're building (product understanding)

Captured from the Gather Brand & Product deck (19 frames) and the pitch narrative.

### The experience loop
1. **By request, not by download** — cinematic candlelit welcome; request an invitation or enter an invite code.
2. **Waitlist by city & cohort** — pick your city, add email, see your position ("214 ahead of you in Sydney"); tables open neighbourhood by neighbourhood (Surry Hills first). Scarcity and curation from the first screen.
3. **Compatibility quiz** — intent (new friends / conversation / networking / dating-curious), availability (days free), and conversation style (listener / talker / both). This becomes the matching signal.
4. **Pick a membership tier** — Core, Unlimited, or invite-only Black.
5. **This week's invitation** — home dashboard: the weekly invite, stats (dinners attended, new connections), recent connections, upcoming/waitlisted.
6. **The invitation** — vetted venue (cuisine, rating, price, distance), a **table match score** (e.g. 92%), what the night includes (welcome drink, guided conversation cards, optional after-party).
7. **Confirm the seat** — **$20 refundable deposit**, returned on show-up, forfeited on no-show; free cancellation up to 24h. This is the accountability differentiator.
8. **Your table** — see the six people and *why* you were matched (per-person match %, short bios).
9. **The table thread** — group chat before, during and after; logistics, welcome drink, optional after-party nearby, photo sharing, conversation prompts.
10. **Rate & reconnect** — star the night, keep the people you clicked with; picks quietly feed next week's matching.
11. **Your crew** — persistent connections and self-organising groups ("plan a dinner"); the retention/continuity layer.
12. **Membership & profile** — transparent renewal, visible show-up rate, dining preferences, pause-or-cancel in one tap; Black inner-circle invitation flow.

### Membership tiers
| Tier | Price | Includes |
|---|---|---|
| **Core** | $1.99/mo | Pay-as-you-dine — $49 per event |
| **Unlimited** *(most chosen)* | $44.99/mo | All standard dinners, priority RSVP |
| **Black** | Invite only | Private RSVP formats, chef's-table & premium, concierge curation; pricing shared privately |

### Design system (already defined — a major head start)
- **Aesthetic:** Dark · Gold · Glass · Editorial. Warm near-black ink base (`#0B0B0C`), three surface depths, gold (`#C9A961`) as the single signature accent, cream (`#F5EFE6`) for type.
- **Themeable accent token:** one token swaps gold → deep wine (intimate) or sage (daytime/friendship) without touching structure — "gold ships first; wine and sage are seasonal/city moods."
- **Type:** Bricolage Grotesque (display/wordmark/match scores) + Hanken Grotesk (interface/body/data).
- **Brand mark:** the dining-table-as-"G" monogram with six gem seats.
- **Feel:** cinematic, candlelit, glassmorphism, premium — this is a high-polish bar, and the estimate reflects that.

---

## 3. Recommended technical architecture

Chosen for a **solo builder moving at agentic speed**: managed services over self-hosted infrastructure, one language across the stack, and tooling Claude Code is highly fluent in.

| Layer | Recommendation | Why |
|---|---|---|
| **Mobile app** | **React Native + Expo** (TypeScript) | One codebase → iOS + Android; huge ecosystem; fastest path for a solo dev; excellent AI-assisted velocity. EAS handles builds & OTA updates. |
| **Backend / DB** | **Supabase** (Postgres, Auth, Realtime, Storage, Edge Functions, Row-Level Security) | Auth, database, realtime chat, file storage and serverless functions in one managed platform — minimal ops for a solo builder. |
| **Payments** | **Stripe** (Subscriptions, PaymentIntents with manual capture for deposits, Connect later if paying venues) | Handles all three tiers, pay-per-event, and the refundable-deposit hold/capture/refund mechanics. |
| **Realtime chat** | Supabase Realtime for MVP (upgradeable to Stream/Sendbird if chat becomes richer) | Table threads before/during/after the night. |
| **Push notifications** | Expo Push → APNs/FCM | Invitations, RSVP reminders, table messages, deposit/check-in nudges. |
| **Maps / location** | Mapbox or Google Places | Venue distance ("12 min away"), city/neighbourhood logic. |
| **Curator back-office** | Lightweight web app (Next.js) on the same Supabase | You need somewhere to run the dinners (see §4). |
| **Analytics / monitoring** | PostHog + Sentry | Funnel, retention, crash/error visibility. |
| **Deep linking** | Expo Linking / branch | Invite codes and shareable invitations. |

---

## 4. The thing most people forget: the operations back-office

The magic of Gather — "the right room," "matched to you," "a vetted venue" — is **curated, not automatic**, especially for v1. Someone (you, initially) has to source and vet venues, open cohorts, form the tables, and watch deposits and check-ins. That means a **curator/admin web tool is not optional** — it's how the product actually runs. It is included in the MVP scope below and is one of the more commonly under-estimated pieces.

For v1, matching is a **rule-based/heuristic scoring engine** (from intent, availability, style, and rating history) that **proposes** tables for a human curator to approve — not a machine-learning system. True data-driven matching is a Phase 2 investment that only pays off once there's dinner history to learn from.

---

## 5. Key product & technical decisions to make

These shape scope, cost, and legal exposure. My recommendation is given for each; the ones marked ⚠️ genuinely need your (or counsel's) sign-off before build.

1. **⚠️ Payments & the App Store cut.** Access to *in-person dining events* is a real-world service, which under Apple's guidelines is **exempt from mandatory In-App Purchase** — so memberships and deposits can run through **Stripe** (no 15–30% Apple tax). This is favourable and material to the business model, but Apple review is discretionary; worth confirming early and keeping the "real-world service" framing tight in the UI. *Recommendation: Stripe, external payments, with a fallback plan.*
2. **Deposit mechanics & check-in.** How is "show-up" verified to release the $20? Options: host/curator confirms attendance, member self-checks-in via geofence, or a QR at the table. *Recommendation: curator confirmation for MVP (simplest, most reliable), geofence later.* Implemented as a Stripe manual-capture hold → released or captured.
3. **⚠️ Trust & safety.** Strangers meeting IRL, including "dating-curious," raises real duty-of-care. Minimum viable: reporting/blocking, a code of conduct, curator moderation of table threads, and clear safety guidance. *Recommendation: include the baseline in MVP (scoped in Phase 9); ID verification is Phase 2.*
4. **Launch city & cohort strategy.** MVP should nail **one city (Sydney / Surry Hills)** end-to-end before multi-city. *Recommendation: single-city MVP; multi-city is a Phase 2 scale item.*
5. **Black tier for v1.** Full concierge tooling is heavy. *Recommendation: MVP ships the *invitation* and gated formats; concierge curation is handled manually / off-app initially.*
6. **Matching depth.** *Recommendation: heuristic + human-in-the-loop for MVP (see §4).*
7. **Guided conversation cards / prompts content.** Who writes them? *Recommendation: a small starter set authored during build; a content pipeline later.*
8. **⚠️ Legal & compliance.** Terms of service, privacy policy (PII + location + payments), event-liability and alcohol considerations, refund policy. *Recommendation: templated docs reviewed by an Australian lawyer — budget separately; not included in day-rate below.*
9. **Notifications & comms.** Transactional email/SMS (waitlist, receipts, reminders) via Resend/Postmark + Twilio. *Recommendation: included in MVP at a basic level.*
10. **Data model for continuity.** Connections, crews, and rating history must be modelled from day one so the "moat" compounds. *Included in the Phase 0 data-model work.*

---

## 6. Delivery approach — agentic, with iteration built in

The build runs as a **solo, AI-augmented workflow**: you drive product decisions and review; Claude Code does the heavy lifting of implementation, scaffolding, refactors, and test-writing. That's why the coding phases are compressed well below traditional estimates.

What *doesn't* compress — and is where the buffer lives:
- **Your review-and-iterate cycles.** Each surface goes build → you react → refine. The day ranges below already carry this back-and-forth; the "recommended planning number" adds explicit contingency on top.
- **Payment & deposit edge cases**, refunds, failed captures, chargebacks.
- **Real-device QA** across iOS and Android.
- **App Store / Play review**, including the chance of a rejection round.

**Cadence:** work in **1–2 week phase blocks**, each ending with a testable build (TestFlight / internal Android track) for you to try on a real phone and give feedback before the next block starts. This keeps iteration cheap and prevents late surprises.

---

## 7. Phased timeline & cost (MVP — launch in one city)

Day ranges are working days for a solo AI-augmented build. Iteration/back-and-forth is embedded in the ranges; the recommended total adds contingency on top.

| # | Phase | Deliverable | Days (low–high) |
|---|---|---|---|
| 0 | **Foundations** | Architecture, Supabase + Expo + Stripe setup, environments, CI/EAS, **full data model** (members, cohorts, venues, tables, connections, crews, deposits) | 3–4 |
| 1 | **Design system → code** | RN component library from the deck (type, tokens, glass surfaces, buttons, cards, match-score UI), themeable accent, 4-tab nav shell | 4–6 |
| 2 | **Onboarding & waitlist** | Cinematic welcome, request/invite-code auth, city + email, waitlist position, cohort model, compatibility quiz, deep-linked invite codes | 4–6 |
| 3 | **Membership & payments** | Stripe: 3 tiers, subscriptions, pay-per-event, renewal, one-tap cancel; App Store compliance handling | 5–8 |
| 4 | **The Loop (invite → RSVP → deposit)** | Home dashboard + stats, weekly invitation, venue detail + match score, confirm-seat, **refundable deposit hold**, waitlist states, check-in | 5–7 |
| 5 | **The table & live chat** | Table reveal (6 members + per-person match), realtime group thread (before/during/after), after-party, photo share, prompts, push notifications | 5–7 |
| 6 | **Continuity — rate, reconnect, crew** | Post-dinner rating, keep-connections, crew/groups, plan-a-dinner, connections list, feedback into matching | 4–5 |
| 7 | **Matching engine v1** | Heuristic compatibility scoring + curator-assisted table formation | 3–5 |
| 8 | **Curator / admin back-office** | Web tool: cities/cohorts, venues, waitlists, form tables, send invitations, monitor deposits & check-ins, moderation | 5–7 |
| 9 | **Trust, safety & profile** | Reporting/blocking, code of conduct, You/membership screen, show-up rate, preferences, pause/cancel | 3–4 |
| 10 | **Polish, motion & theming** | Cinematic transitions, glass polish, wine/sage themes, empty/error states, accessibility pass | 3–5 |
| 11 | **QA & hardening** | End-to-end + payment/deposit edge cases, real-device iOS & Android testing, bug-fix | 4–6 |
| 12 | **Store submission & launch** | App Store + Play listings, screenshots, privacy declarations, review (incl. rejection buffer), production deploy & monitoring | 2–4 |
| | **MVP subtotal** | | **50–74 days** |

### Cost summary

| Scenario | Days | Cost @ $1,000/day |
|---|---|---|
| Focused / agentic pace | ~50 | **$50,000** |
| **Recommended (with iteration buffer)** | **~65** | **$65,000** |
| Conservative (max buffer) | ~74 | $74,000 |

*Recommended figure = phase midpoints (~59 days) + ~10% contingency for scope-discovery and review cycles.*

**Optional payment structure:** 30% to start ($19,500), then progress payments at the end of Phases 3, 6, and 9, with the balance on store submission. Or a simple weekly draw at the day rate against a soft cap.

---

## 8. Out of scope for MVP (Phase 2 / future)

Deferred deliberately so v1 launches lean and proves the loop in one city:

- **Data-driven / ML matching** (once there's dinner history to learn from)
- **Multi-city scale** and ops automation (self-serve cohort opening, regional curators)
- **Black tier native tooling** — concierge dashboard, private/chef's-table formats in-app
- **Venue self-serve portal** and venue payouts (Stripe Connect)
- **Growth loops** — referrals, gifting a seat, member invites with tracking
- **Member web app** (companion to mobile)
- **Advanced analytics/BI**, cohort retention dashboards
- **Memories** — richer photo galleries, post-dinner recaps, social sharing
- **ID verification** and enhanced trust & safety
- **Loyalty / status mechanics** beyond show-up rate

Each is a natural follow-on engagement, quotable once the MVP is live and learning.

---

## 9. Assumptions

- **One launch city** (Sydney) for MVP.
- **Matching is heuristic + human-curated** for v1 (not ML).
- **You own the business side:** venue sourcing/partnerships, curation decisions, cohort strategy, and content sign-off. The app gives you the tools to run it.
- **Brand & design are already defined** (this deck) — no separate design discovery; the design phases are *implementation* of your system, with light refinement.
- **Stripe is used for payments** under Apple's real-world-service exemption, pending final confirmation.
- **Legal (T&Cs, privacy policy) and third-party costs are separate** from the day rate — see below.
- **You provide** Apple Developer + Google Play accounts, domain, and any paid API keys (Mapbox, Twilio, etc.).

### Costs not included in the day rate (pass-through / your accounts)
- Apple Developer ($99/yr) & Google Play ($25 once)
- Supabase, Stripe fees, Mapbox/Places, push/email/SMS, Sentry/PostHog (mostly usage-based; low at launch)
- Legal review of terms, privacy, liability (recommend an AU lawyer)
- Any premium design assets, fonts licensing (Bricolage/Hanken — confirm licences)

---

## 10. Why this is a strong engagement

- **The hard part is already done twice over:** a complete, opinionated design system *and* a clear product narrative. Most builds spend weeks discovering what Gather already knows.
- **The differentiators are buildable and defensible** — the deposit-accountability loop and the continuity/crew layer are concrete features, not vibes.
- **Agentic delivery makes a premium, category-defining app affordable for a solo founder-operator** — roughly a third of agency cost and half the time — without cutting the polish the brand demands.

---

## 11. Next steps

1. Confirm the **recommended ~$65k / ~13-week** scope, or tell me where to trim (e.g. defer the Black invitation flow, or ship Android second) to hit a lower number.
2. Lock the **⚠️ decisions** in §5 — especially payments/App-Store and the trust-&-safety baseline.
3. Sign off the **launch city and first cohort** plan.
4. Kick off **Phase 0** — I'll have a running skeleton (auth + nav + design tokens) on your phone within the first block.

*Let's set the table.*
