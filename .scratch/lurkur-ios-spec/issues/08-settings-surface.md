# 08 — What settings surface does the SPEC require?

**Type:** grilling  
**Status:** resolved  
**Blocked by:** 01

## Question

Confirm the exact Settings list for SPEC: keep Flutter prefs **except** theme color seeds and HTML-text toggle; brightness stays; content rendering has no user toggle (see research). Lock labels/behavior for density, autoplay, hide AutoMod, hidden subreddits, clear settings, logout, and anything else the inventory surfaces.

## Answer

Settings tab uses a grouped `Form` with:

| Section | Items |
|---|---|
| **Appearance** | Brightness: light / dark / system |
| **Comments** | Hide AutoModerator comments (toggle) |
| **Hidden subreddits** | List + unhide; hide also available from post more-actions |
| **Session** | Clear all settings (confirmation) · Log out |

**Not in Settings (dropped vs Flutter):** theme color seeds, HTML-text toggle, density, autoplay toggle.

**Video policy (SPEC-wide):** **never autoplay** — user must start playback; no autoplay preference UI.
