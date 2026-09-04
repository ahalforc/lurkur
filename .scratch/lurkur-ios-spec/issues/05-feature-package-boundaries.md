# 05 — How do feature packages vs the shared Reddit client divide work?

**Type:** grilling  
**Status:** resolved  
**Blocked by:** 01

## Question

Standing preference: feature packages own views + state; one shared module owns Reddit HTTP + models. Using the Flutter capability inventory, lock package boundaries (Auth, Feed, Browse, Post, Settings, shared client) — what may live in shared vs must stay inside a feature, and how auth tokens reach feature stores.

## Answer

**Layout**

| Location | Owns |
|---|---|
| **Core/** | Auth (session, Keychain, OAuth/token exchange, WKWebView auth helper), Reddit (HTTP, Codable models, mapping helpers — no feature UI), Preferences (prefs store) |
| **Features/** | Auth UI (sign-in), Feed (Home/Popular/subreddit listings + cards), Browse (subscriptions + go-to), Post (detail + comments + more-actions), Settings (settings UI only) |
| **App/** | Tab shell, auth gate, environment wiring |

**Rules**

- Features **must not** import other features (strict).
- Features may import **Core** only (plus what App injects via environment).
- `RedditClient` reads the access token from Core Auth — features do not pass tokens on each call.
- No shared Components package — duplicate SwiftUI (cards/media/etc.) inside Feed and Post as needed.
- Settings feature is UI over Core Preferences; Feed/Post/Browse read prefs via environment from Core.
