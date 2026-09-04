# 07 — How should the system shell present Home / Popular / Browse / Settings?

**Type:** grilling  
**Status:** resolved  
**Blocked by:** 02

## Question

IA stays Home / Popular / Browse + Settings. Using Liquid Glass / latest-iOS research, lock how that chrome is specified: tab placement, Settings as tab vs sheet vs `settings` link, iPad large-canvas rules, and any Liquid Glass-specific requirements the SPEC must state.

## Answer

- **Shell:** four-tab system `TabView` — Home, Popular, Browse, **Settings** (Settings is a peer tab with grouped `Form` in its stack — not a Flutter-style sheet).
- **Navigation:** each tab owns its own `NavigationStack`.
- **iPhone:** `.tabBarMinimizeBehavior(.onScrollDown)`.
- **iPad:** same four destinations; larger canvas; **`sidebarAdaptable` allowed but not required**; no app-wide `NavigationSplitView` requirement.
- **Browse:** normal tab (not `Tab(role: .search)`); `.searchable` on the Browse stack is fine if useful.
- **Platform chrome:** iOS 26 / iPadOS 26 only; adopt system Liquid Glass; do **not** set `UIDesignRequiresCompatibility`; Liquid Glass on navigation chrome only — not on feed/post content cards.
