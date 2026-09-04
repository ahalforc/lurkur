# 01 — What user-visible capabilities does Flutter lurkur expose?

**Type:** research  
**Status:** resolved  
**Blocked by:** None — can start immediately

## Question

Produce a parity checklist of every user-visible capability in `apps/flutter/` (screens, actions, prefs, media types, navigation) that lurkur-ios must cover for functional parity — citing Flutter source files. Exclude dead code paths that are never reachable from the UI.

## Answer

Flutter lurkur is a read-only Reddit client: auth WebView → Home/Popular/Browse shell (+ Settings sheet), density-aware feeds with sort/refresh/infinite scroll, submission detail (link + threaded comments), hide-subreddit / show-JSON actions, and prefs for brightness, density, autoplay, HTML text, AutoMod hide, and hidden subreddits. Full inventory with file citations: [assets/01-flutter-capability-inventory.md](../assets/01-flutter-capability-inventory.md).
