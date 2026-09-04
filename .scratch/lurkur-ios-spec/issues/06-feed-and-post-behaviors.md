# 06 — What feed and post behaviors must the SPEC require?

**Type:** grilling  
**Status:** resolved  
**Blocked by:** 01

## Question

From the Flutter inventory, which feed/post behaviors are mandatory in SPEC (sort, pagination/infinite scroll, pull-to-refresh, card density, media variants image/gallery/video/link, comments tree, more-actions / hide subreddit, submission presentation as sheet vs push, etc.)? Explicitly list anything Flutter has that we will still drop despite “functional parity.”

## Answer

### Required

**Feeds (Home / Popular / subreddit):** sort (hot + top time windows), pull-to-refresh, infinite scroll, loading/error, filter hidden subreddits, subreddit banner when available. Cards always use **large** preview (self / gallery / video / metadata tags) — not density-varying compact/medium modes. Video uses **system player defaults** only.

**Post:** open via **navigation push**. Full submission card; open links in-app WebView; threaded comments (expand/collapse, OP/edited tags, `preview.redd.it` image special-case, hide AutoMod); bodies via Markdown (ticket 03).

**More-actions:** **hide subreddit** only.

**Debug:** `os.Logger` (or Unified Logging) for auth, Reddit client, feed, and post — no in-app JSON viewer.

### Explicitly dropped vs Flutter

- Density-driven compact/medium feed card modes; **density preference entirely**
- Custom video autoplay / visibility-pause / tap-overlay / drag-seek UI
- Show raw JSON more-action
- Sheet-style submission detail (use push instead)
