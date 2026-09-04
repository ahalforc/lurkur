# lurkur-ios SPEC map

Label: `wayfinder:map`

## Destination

A durable `apps/lurkur-ios/docs/SPEC.md` (with `AGENTS.md` pointing at it) that specifies Flutter-functional-parity for lurkur-ios on **iPhone and iPad** — enough that implementation can proceed without reopening product scope. This map produces the written spec, not the implemented app.

## Notes

- **Domain:** Reddit reader migration; legacy source of truth is `apps/flutter/`; replacement app is `apps/lurkur-ios/`.
- **Skills:** `/grilling`, `/domain-modeling`, `/research`; after the map clears, hand off to `/to-tickets` or `/implement` as needed.
- **Standing preferences (from charting):**
  - Spec lives at `apps/lurkur-ios/docs/SPEC.md` (single file); depth = user-facing behavior + architecture sketch.
  - Platforms: iPhone + iPad; **Mac explicitly out of scope** in the SPEC.
  - Networking: **in-app only** (direct Reddit); no BFF/backend.
  - UI: SwiftUI-native; system defaults / Liquid Glass; **newest OS only**.
  - Shell IA: four-tab Liquid Glass `TabView` (Home / Popular / Browse / **Settings tab**); per-tab `NavigationStack`; minimize-on-scroll iPhone; iPad `sidebarAdaptable` optional; iOS 26–only.
  - Code shape: **App/** + **Core/** (Auth, Reddit, Preferences) + **Features/** (Auth UI, Feed, Browse, Post, Settings). Features never import features; no shared Components — duplicate UI per feature. Reddit client reads token from Core Auth.
  - Parity: clone Flutter **functionality**; fix clear bugs (intent parity).
  - Prefs / Settings: brightness; hide AutoMod; hidden subreddits (+ more-actions hide); clear all; logout. Drop theme color, HTML toggle, density, autoplay toggle. **Videos never autoplay.**
  - Auth: **WKWebView + `https://www.reddit.com` intercept** (full contract locked in ticket 04); ASWebAuth deferred.
  - iPad: same tab shell, larger canvas — no split-view requirement in v1 SPEC.
- **Override:** after decision tickets clear, one in-map **task** assembles `docs/SPEC.md` from Decisions so far (destination is the written file).

## Decisions so far

- [What user-visible capabilities does Flutter lurkur expose?](issues/01-flutter-capability-inventory.md) — Read-only Reddit client: auth + Home/Popular/Browse(+Settings), density-aware feeds/media, post detail+comments, hide-subreddit, and listed prefs (see asset).
- [What do Liquid Glass / latest-iOS shell patterns imply for this app?](issues/02-liquid-glass-shell-patterns.md) — Four-tab Liquid Glass `TabView` keeps Home/Popular/Browse/Settings; iOS 26–only system chrome, Settings as in-app tab+Form, no IA rename required.
- [How should SwiftUI render Reddit post and comment bodies?](issues/03-reddit-content-rendering.md) — Markdown via `AttributedString(markdown:)` + `Text` from `selftext`/`body` (no HTML toggle)
- [Which auth mechanism should lurkur-ios use?](issues/04-auth-mechanism.md) — WKWebView + `https://www.reddit.com` intercept; full Keychain/scopes/UX contract in SPEC; ASWebAuth deferred
- [How do feature packages vs the shared Reddit client divide work?](issues/05-feature-package-boundaries.md) — App + Core (Auth/Reddit/Preferences) + Features; no feature→feature imports; duplicate UI; client gets token from Auth
- [What feed and post behaviors must the SPEC require?](issues/06-feed-and-post-behaviors.md) — Full feeds; large-only cards; push post detail; hide-subreddit; os.Logger; drop density/custom video/show-JSON
- [How should the system shell present Home / Popular / Browse / Settings?](issues/07-shell-chrome.md) — Four-tab Liquid Glass TabView; Settings as tab+Form; minimize-on-scroll; iPad sidebarAdaptable optional; iOS 26–only
- [What settings surface does the SPEC require?](issues/08-settings-surface.md) — Brightness, hide AutoMod, hidden subs, clear, logout; never autoplay; drop density/HTML/color/autoplay toggle
- [What outline and architecture depth belong in SPEC.md?](issues/09-spec-outline-and-depth.md) — 12-section SPEC; package map + dir names; must-haves/non-goals; AGENTS pointer + thin CONTEXT.md
- [Assemble docs/SPEC.md from locked decisions](issues/10-assemble-spec.md) — Wrote `apps/lurkur-ios/docs/SPEC.md`, `CONTEXT.md`, and slim `AGENTS.md`

## Not yet specified

- How implementation tickets are cut after SPEC exists (post-map `/to-tickets`).

## Out of scope

- Implementing the iOS app on this map (except assembling SPEC.md).
- Mac UX in the SPEC.
- BFF / any backend.
- Reddit write actions Flutter does not expose (vote, comment, subscribe/unsubscribe APIs).
- Theme color-seed cycling; user-facing HTML-text toggle; **density preference**; custom video chrome; show-JSON more-action; **video autoplay** (and autoplay pref).
- Pixel-perfect Flutter/Material recreation.
- App Store packaging / marketing icons as a planning concern.
