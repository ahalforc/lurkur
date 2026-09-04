# lurkur-ios product SPEC

Product behavior and architecture sketch for the SwiftUI Reddit reader that replaces the legacy Flutter app. Implementation should follow this document without reopening product scope.

Source of intent: Flutter lurkur (`apps/flutter/`), with deliberate divergences listed under **Out of scope** and per-section non-goals. Planning decisions live in `.scratch/lurkur-ios-spec/`.

---

## Overview

lurkur-ios is a **read-only** Reddit client: sign in, browse feeds, open posts and comments, manage light preferences. It talks to Reddit **directly** from the app (no BFF). UI is SwiftUI-native with system Liquid Glass chrome—not a Material/Flutter pixel clone.

---

## Platforms

| In scope | Notes |
|---|---|
| **iPhone** | Primary |
| **iPad** | Same tab IA, larger canvas |

| Out of scope | Notes |
|---|---|
| **Mac** | Explicitly out of this SPEC (project may still be multiplatform in Xcode) |

**Deployment:** iOS 26 / iPadOS 26 only. Adopt system Liquid Glass. Do **not** set `UIDesignRequiresCompatibility`.

---

## Architecture

### Package map

```
App/           # Tab shell, auth gate, environment wiring
Core/
  Auth/        # Session, Keychain, OAuth/token exchange, WKWebView auth helper
  Reddit/      # HTTP client, Codable models, mapping helpers (no feature UI)
  Preferences/ # Prefs store
Features/
  Auth/        # Sign-in UI
  Feed/        # Home / Popular / subreddit listings + cards
  Browse/      # Subscriptions + go-to subreddit
  Post/        # Detail, comments, more-actions
  Settings/    # Settings Form UI only
```

### Rules

- Features **must not** import other features.
- Features may import **Core** only (plus App-injected environment).
- `RedditClient` obtains the access token from Core Auth—features do not pass tokens on each call.
- No shared Components package: duplicate SwiftUI (cards, media, etc.) inside Feed and Post as needed.
- Settings UI reads/writes Core Preferences; Feed / Post / Browse read prefs via environment.

### State

Prefer simple SwiftUI / `@Observable` patterns. Keep theming and state management minimal.

---

## Auth

### Must-haves

- Unauthorized users see sign-in; authorized users see the tab shell.
- Sign-in opens a **sheet** with a **non-ephemeral `WKWebView`**.
- Authorize at `https://old.reddit.com/api/v1/authorize` with scopes `mysubreddits read subscribe`, `duration=permanent`, `redirect_uri=https://www.reddit.com`, `response_type=code`, and a CSRF `state`.
- Intercept navigations whose URL has prefix `https://www.reddit.com` and extract `state` + `code`.
- Exchange / refresh via `POST https://www.reddit.com/api/v1/access_token`; treat `expires_in` as **seconds**.
- Persist access token, refresh token, and expiration in Keychain with accessibility **`AfterFirstUnlockThisDeviceOnly`**.
- On launch: restore session; refresh if expired; logout clears Keychain.
- Keychain write failure **fails** the token exchange (do not leave an authorized UI without persisted credentials).
- Canceling the auth sheet returns to unauthorized **without** clearing already-stored tokens.

### Non-goals

- `ASWebAuthenticationSession` (would require a different Reddit redirect URI).
- Changing redirect URI away from `https://www.reddit.com`.
- Multi-account.
- Subscribe/unsubscribe API usage (scope may remain for parity with Flutter’s request).

---

## Shell

### Must-haves

- Four-tab system `TabView`: **Home**, **Popular**, **Browse**, **Settings**.
- Each tab owns its own `NavigationStack`.
- Settings is a **peer tab** with a grouped `Form` (not a modal sheet like Flutter).
- iPhone: `.tabBarMinimizeBehavior(.onScrollDown)`.
- Liquid Glass on **navigation chrome only**—not on feed/post content cards.
- Browse is a **normal** tab (not `Tab(role: .search)`); `.searchable` on the Browse stack is allowed.

### Non-goals

- App-wide `NavigationSplitView`.
- Flutter bottom-nav + Settings-as-sheet chrome.
- Custom glass materials wrapping list/card content.
- Requiring `sidebarAdaptable` (allowed on iPad as an optional enhancement).

---

## Feed

Covers Home (user multi-home), Popular, and pushed named subreddits.

### Must-haves

- Load submissions from Reddit OAuth API (home listing vs `/r/{name}/{sort}`).
- Sort: **hot** and **top** with time windows (hour/day/week/month/year/all); default hot.
- Pull-to-refresh; infinite scroll / load-more; loading and error UI.
- Filter out subreddits the user has hidden.
- Subreddit banner image in the nav area when `/about` provides one (not for home/popular).
- Cards always use **large** preview: metadata tags (subreddit, author, NSFW, pinned, stickied, score, comments, relative time); self / gallery carousel / video as applicable.
- Tapping a submission **pushes** Post (see Post).
- Long-press (or equivalent) exposes more-actions: **hide subreddit** only.
- **Session persistence:** Across navigation that leaves a feed in the stack (post push/pop, tab switches, Browse→subreddit→back), keep listing session state — already-loaded pages, current sort, and scroll position. Do not remount into a full-screen loading state on re-appear. Reload (discard session) only on pull-to-refresh, sort change, a different feed target, or logout / clear settings. Hide-subreddit filters the in-memory list; it does not reload.

### Non-goals

- Density-varying compact/medium card modes.
- Custom video chrome (autoplay-on-visible, overlay play/pause, drag-seek)—use system player controls, with **never autoplay** (user starts playback).
- Voting or other write actions.
- Explicit scroll-offset save/restore APIs (rely on keep-alive so the system preserves position).

---

## Browse

### Must-haves

- List subscribed subreddits (A–Z), refresh.
- Tap subscription → push that subreddit feed (Feed feature).
- Free-text “go to subreddit” by name → push feed.

### Non-goals

- Subscribe/unsubscribe.
- Full Reddit search beyond go-to-by-name.
- `Tab(role: .search)` chrome.

---

## Post

### Must-haves

- Presented via **navigation push** from a feed.
- Full submission card (same large media rules as Feed).
- External link row opens an **in-app WebView**.
- Threaded comments: expand/collapse, author (empty → Deleted), score, OP/edited tags.
- Comment/self bodies via Markdown (see Content rendering).
- Bodies that are a `https://preview.redd.it/…` URL show as an inline image.
- Honor **Hide AutoModerator** preference when rendering comments.
- More-actions: **hide subreddit** (updates Core Preferences **and pops** back to the feed).

### Non-goals

- Sheet/detent primary presentation (Flutter popup).
- Show raw JSON.
- Reply / vote / award / save / system share.

---

## Settings

Grouped `Form` on the Settings tab:

| Section | Items |
|---|---|
| Appearance | Brightness: light / dark / system |
| Comments | Hide AutoModerator comments |
| Hidden subreddits | List + unhide |
| Session | Clear all settings (confirm) · Log out |

### Non-goals

- Theme color seeds.
- HTML-text toggle.
- Density preference.
- Autoplay preference (video never autoplays; no toggle).

---

## Content rendering

### Must-haves

- Default for post selftext and comment bodies: parse Reddit `selftext` / `body` with `AttributedString(markdown:)` into SwiftUI `Text`.
- On parse failure: fall back to plain `Text`.
- No user-facing HTML vs plain toggle.

### Non-goals

- Rendering `*_html` fields as the primary source.
- Shipping an HTML toggle like Flutter.

---

## Logging

### Must-haves

- Use `os.Logger` / Unified Logging for Auth, Reddit client, Feed, and Post (enough to debug OAuth and API failures in Console).

### Non-goals

- In-app log viewer or show-JSON debug UI.

---

## Out of scope

- Implementing beyond this SPEC’s product surface (cut implementation tickets separately).
- Mac UX.
- Any backend / BFF.
- Reddit write APIs Flutter does not expose (vote, comment, subscribe/unsubscribe).
- Pixel-perfect Flutter/Material recreation.
- App Store packaging / marketing icon work as a product requirement.
- `ASWebAuthenticationSession` / custom-scheme OAuth redirect.
- Video autoplay and density/HTML/theme-color preferences.
