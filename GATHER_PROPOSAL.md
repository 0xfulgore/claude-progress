# Gather — Proposal & Scope of Work

**Prepared by:** Gary Shannon
**Date:** 9 July 2026
**Engagement model:** Solo build, AI-augmented (Claude Code), agentic delivery
**Day rate:** AUD $1,000 / day

---

## 1. Executive summary

**Gather** is a premium, invitation-only curated dining membership club delivered as a native mobile app. Members receive **one curated dinner invitation a week** — a table of six compatible people at a vetted venue — with the whole experience engineered end-to-end: onboarding by request, compatibility-based matching, a refundable deposit that guarantees real seats, a live table thread before and after the night, and a continuity layer that turns one dinner into a lasting "crew."

The product is deliberately not a feed and not a swiping app. Its differentiators are **curation, accountability (the refundable deposit), honest transparent pricing, and continuity** — the last being described in your own deck as "the moat."

This document translates the Gather design system and product deck into a concrete, buildable scope, sets out every material technical and product decision, and gives an honest, agentic-paced plan to a **launch-ready MVP in one city in around eight weeks.**

**Bottom line:**

| Track | Time | Cost @ $1,000/day |
|---|---|---|
| **The 8-week sprint** *(recommended)* | **~8 weeks · 40 working days** | **$40,000** |
| Could land sooner | ~6–7 weeks | ~$30k–$35k |
| Could extend | ~10 weeks | ~$50k |

Roughly **2.5 of those 8 weeks are reserved for iterative fine-tuning** — reacting to the app on your phone, polishing, and hardening — not still writing features. For context, a traditional agency would quote **$150k–$300k+ and 6–9 months** for a payments-and-realtime-heavy, two-sided mobile product plus its operations tooling.

### A note on estimating a build like this in 2026

AI-assisted development has genuinely changed what one person can ship, and how fast — this proposal only exists at this price and pace *because* of it. The honest truth is that it also makes a build **harder to pin to an exact date** than it used to be: the same tailwind that lets a solo builder move at this speed makes each individual week less predictable.

So treat **8 weeks as the number to plan around.** With scope frozen and momentum on our side, it could land a week or two sooner. If payments, App Store review, or real-world iteration throw a curveball, it could stretch a few weeks the other way. The range is the point — anyone quoting you a precise, guaranteed date for a build like this, in this landscape, is projecting more confidence than the tools honestly justify. What I can commit to is a **testable build on your phone every week**, so you always see exactly where it stands.

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
- **Feel:** cinematic, candlelit, glassmorphism, premium — this is a high-polish bar, and the plan reserves real fine-tuning time to hit it.

---

## 3. Recommended technical architecture

Chosen for a **solo builder moving at agentic speed**: managed services over self-hosted infrastructure, one language across the stack, and tooling Claude Code is highly fluent in.

| Layer | Recommendation | Why |
|---|---|---|
| **Mobile app** | **React Native + Expo** (TypeScript), **iOS first** | One codebase, iOS-first for the sprint with Android as a fast-follow; EAS handles builds & OTA updates. |
| **Backend / DB** | **Supabase** (Postgres, Auth, Realtime, Storage, Edge Functions, RLS) | Auth, database, realtime chat, storage and serverless functions in one managed platform — minimal ops for a solo builder. |
| **Payments** | **Stripe** (Subscriptions, PaymentIntents with manual capture for deposits) | All three tiers, pay-per-event, and the refundable-deposit hold/capture/refund mechanics. |
| **Realtime chat** | Supabase Realtime for MVP | Table threads before/during/after the night. |
| **Push notifications** | Expo Push → APNs/FCM | Invitations, RSVP reminders, table messages, deposit/check-in nudges. |
| **Maps / location** | Mapbox or Google Places | Venue distance ("12 min away"), city/neighbourhood logic. |
| **Curator ops** | Thin admin for the sprint (Supabase Studio + scripts/screens); polished Next.js back-office as a fast-follow | You run the first cohorts semi-manually, then invest once the loop is proven. |
| **Analytics / monitoring** | PostHog + Sentry | Funnel, retention, crash/error visibility. |
| **Deep linking** | Expo Linking / branch | Invite codes and shareable invitations. |

---

## 4. The thing most people forget: the operations layer

The magic of Gather — "the right room," "matched to you," "a vetted venue" — is **curated, not automatic**, especially for v1. Someone (you, initially) has to source and vet venues, open cohorts, form the tables, and watch deposits and check-ins.

To protect the 8-week timeline, the sprint ships a **thin operations layer** — Supabase Studio plus a handful of admin scripts and screens — enough for you to run the first small cohorts by hand. The **polished curator back-office** (a proper Next.js web tool) is the first fast-follow after launch, built once the loop has proven itself and you know exactly what the ops workflow needs to be.

For v1, matching is a **rule-based/heuristic scoring engine** (from intent, availability, style, and rating history) that **proposes** tables for you to approve — not a machine-learning system. True data-driven matching is a later investment that only pays off once there's dinner history to learn from.

---

## 5. Key product & technical decisions to make

These shape scope, cost, and legal exposure. My recommendation is given for each; the ones marked ⚠️ genuinely need your (or counsel's) sign-off before build.

1. **⚠️ Payments & the App Store cut.** Access to *in-person dining events* is a real-world service, which under Apple's guidelines is **exempt from mandatory In-App Purchase** — so memberships and deposits can run through **Stripe** (no 15–30% Apple tax). This is favourable and material to the business model, but Apple review is discretionary; worth confirming early and keeping the "real-world service" framing tight in the UI. *Recommendation: Stripe, external payments, with a fallback plan.* **This is the one area I will not compress** — it's where an 8-week plan actually slips if it slips.
2. **Deposit mechanics & check-in.** How is "show-up" verified to release the $20? Options: host/curator confirms attendance, member self-checks-in via geofence, or a QR at the table. *Recommendation: curator confirmation for MVP (simplest, most reliable), geofence later.* Implemented as a Stripe manual-capture hold → released or captured.
3. **⚠️ Trust & safety.** Strangers meeting IRL, including "dating-curious," raises real duty-of-care. Minimum viable: reporting/blocking, a code of conduct, curator moderation of table threads, and clear safety guidance. *Recommendation: include the baseline in the sprint; ID verification is a fast-follow.*
4. **Launch city, platform & cohort strategy.** MVP nails **one city (Sydney / Surry Hills), iOS first**, before multi-city or Android. *Recommendation: single-city, iOS-first MVP; Android is the immediate fast-follow.*
5. **Black tier for v1.** Full concierge tooling is heavy. *Recommendation: the sprint ships the *invitation* and gated formats; concierge curation is handled manually / off-app initially.*
6. **Matching depth.** *Recommendation: heuristic + human-in-the-loop for MVP (see §4).*
7. **Guided conversation cards / prompts content.** Who writes them? *Recommendation: a small starter set authored during the build; a content pipeline later.*
8. **⚠️ Legal & compliance.** Terms of service, privacy policy (PII + location + payments), event-liability and alcohol considerations, refund policy. *Recommendation: templated docs reviewed by an Australian lawyer — budget separately; not included in the day rate.*
9. **Notifications & comms.** Transactional email/SMS (waitlist, receipts, reminders) via Resend/Postmark + Twilio. *Recommendation: included at a basic level.*
10. **Data model for continuity.** Connections, crews, and rating history must be modelled from day one so the "moat" compounds. *Included in the week-1 data-model work.*

---

## 6. Delivery approach — an 8-week sprint, iteration built in

The build runs as a **solo, AI-augmented workflow**: you drive product decisions and review; Claude Code does the heavy lifting of implementation, scaffolding, refactors, and test-writing. That's what makes the eight-week pace possible.

**Two rules make 8 weeks real:**
1. **Scope freezes at kickoff.** New ideas during the build go to the Phase 2 / fast-follow list, not into the sprint. Compression only works if the target stops moving.
2. **The whole loop is built before we polish.** By the end of week 5 the end-to-end experience works; weeks 6–8 are for making it feel premium and reacting to what you see — not for last-minute features.

**Cadence:** a **testable build every week** (TestFlight), so iteration is cheap and there are no late surprises. What doesn't compress — payment edge-cases, real-device QA, App Store review, and your review cycles — is deliberately concentrated in the fine-tuning weeks.

---

## 7. The 8-week plan

Five-and-a-half weeks of build, then ~2.5 weeks of iterative fine-tuning and launch. Each week ends on your phone.

| Week | Focus | What ships |
|---|---|---|
| **1** | Foundations + design system → code | Data model, Supabase + Expo + Stripe setup, CI, the RN component library from the deck, themeable accent, 4-tab shell |
| **2** | Onboarding & waitlist | Cinematic welcome, invite-code auth, city + email, cohorts, the compatibility quiz |
| **3** | Membership & payments *(protected core)* | Stripe: 3 tiers, subscriptions, pay-per-event, renewal, one-tap cancel, and the **refundable deposit** hold |
| **4** | The Loop | Home + stats, weekly invitation, venue detail + match score, confirm-seat + deposit, table reveal (6 members + why-matched) |
| **5** | Continuity + close the loop | Realtime table chat + push, after-party, rate → reconnect, crew/groups, heuristic matching, trust-&-safety baseline, thin admin |
| **6** | 🔧 Iterative fine-tuning | Polish, motion, glass, wine/sage theming · **feedback round 1** on real devices |
| **7** | 🔧 Iterative fine-tuning | Real-device QA, payment & deposit edge-cases, bug-fix · **feedback round 2** |
| **8** | 🔧 Launch | App Store listing, screenshots, privacy declarations, review buffer, fixes, production go-live |
| | **Total** | **~8 weeks · 40 working days · $40,000** |

*Weeks 6–8 are the ~2.5 weeks of iterative fine-tuning — deliberately reserved so the premium feel and the edge-cases get real time, not leftover time.*

### Cost summary

| Scenario | Time | Cost @ $1,000/day |
|---|---|---|
| Could land sooner (tailwinds hold, scope frozen) | ~6–7 weeks | ~$30k–$35k |
| **The 8-week sprint (plan around this)** | **~8 weeks** | **$40,000** |
| Could extend (payments/review/scope curveballs) | ~10 weeks | ~$50k |

**Optional payment structure:** 30% to start ($12,000), 40% at the end of week 5 (loop complete), balance on store submission. Or a simple weekly draw at the day rate.

---

## 8. Fast-follows & future phases (deliberately after launch)

To protect the eight weeks, these ship *right after* v1 rather than in it. The first three are near-term (~2–3 weeks combined, ~$10k–$15k); the rest are natural follow-on engagements.

**Immediate fast-follows**
- **Android build & Play Store** (~1–1.5 weeks)
- **Polished curator back-office** (Next.js ops tool)
- **Trust & safety uplift** — ID verification, richer moderation

**Later phases**
- Data-driven / ML matching (once there's dinner history to learn from)
- Multi-city scale and ops automation
- Black tier native tooling — concierge dashboard, private/chef's-table formats in-app
- Venue self-serve portal and venue payouts (Stripe Connect)
- Growth loops — referrals, gift-a-seat, tracked member invites
- Member web app; advanced analytics/BI
- Memories — photo galleries, post-dinner recaps, social sharing
- Loyalty / status mechanics beyond show-up rate

---

## 9. Assumptions

- **One launch city** (Sydney), **iOS first**, for the MVP.
- **Matching is heuristic + human-curated** for v1 (not ML).
- **Scope is frozen at kickoff** — the single biggest lever on hitting 8 weeks.
- **You own the business side:** venue sourcing/partnerships, curation decisions, cohort strategy, and content sign-off. The app gives you the tools to run it.
- **Brand & design are already defined** (this deck) — no separate design discovery; the design work is *implementation* of your system, with light refinement.
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
- **Agentic delivery makes a premium, category-defining app affordable and fast for a solo founder-operator** — a fraction of agency cost and time — without cutting the polish the brand demands.

---

## 11. Next steps

1. Confirm the **~$40k / ~8-week sprint**, understanding the range around it (§1).
2. Agree to **freeze scope at kickoff** — the rule that makes eight weeks real.
3. Lock the **⚠️ decisions** in §5 — especially payments/App-Store, safety, and legal.
4. Sign off the **launch city, iOS-first call, and first cohort** plan.
5. Kick off **week 1** — I'll have a running skeleton (auth + nav + design tokens) on your phone within the first week.

*Let's set the table.*
