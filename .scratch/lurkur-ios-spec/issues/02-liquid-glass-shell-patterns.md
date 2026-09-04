# 02 — What do Liquid Glass / latest-iOS shell patterns imply for this app?

**Type:** research  
**Status:** resolved  
**Blocked by:** None — can start immediately

## Question

Against Apple’s primary docs for the newest iOS, what does a Liquid Glass–era TabView / Settings presentation imply for a multi-tab Reddit reader that keeps Home, Popular, Browse, and Settings? Capture deployment-target consequences of “newest OS only,” recommended chrome patterns, and anything that would force IA changes.

## Answer

Liquid Glass does not force IA changes: keep a four-tab `TabView` (Home / Popular / Browse / Settings), ship iOS 26 / iPadOS 26–only with system glass chrome (no compatibility opt-out), Settings as an in-app tab + grouped `Form`, optional iPhone minimize-on-scroll and iPad `sidebarAdaptable` without renaming destinations.

Full write-up: [assets/02-liquid-glass-shell-patterns.md](../assets/02-liquid-glass-shell-patterns.md)
