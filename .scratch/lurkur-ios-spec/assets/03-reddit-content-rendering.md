# Reddit body/comment rendering for lurkur-ios

**Ticket:** [How should SwiftUI render Reddit post and comment bodies?](../issues/03-reddit-content-rendering.md)  
**Question:** With no HTML toggle, what should be the default SwiftUI approach for Reddit selftext/comments?

---

## Recommendation (one default)

**Render `selftext` / `body` as Markdown via `AttributedString(markdown:)` into SwiftUI `Text`.**  
Do **not** default to HTML (`selftext_html` / `body_html`), plain unparsed text, or a user-facing format toggle.

On parse failure, fall back to plain `Text` of the same string.

---

## What Flutter does today

### Fields Reddit returns (and Flutter keeps)

| Surface | Plain / markup field | HTML field |
|---|---|---|
| Self post | `selftext` → `SelfSubmission.text` | `selftext_html` → `SelfSubmission.textHtml` |
| Comment | `body` → `RedditComment.body` | `body_html` → `RedditComment.bodyHtml` |

Citations:

- `apps/flutter/lib/app/reddit/models/reddit_submission.dart` — `self` maps `selftext` / `selftext_html`
- `apps/flutter/lib/app/reddit/models/reddit_comment.dart` — `body` / `bodyHtml`
- All listing/comment fetches append `?raw_json=1` (`apps/flutter/lib/app/reddit/api/reddit_api.dart`), so HTML is **not** double-escaped as JSON strings

### Toggle + defaults

- Preference key `"use html for text"`; **default `useHtmlForText = false`** (`PreferencesState.empty` in `preferences_cubit.dart`)
- Settings tile: “Use HTML for text” (`settings_popup.dart`)
- Standing map preference: **drop this toggle** on iOS; pick one default here

### Widget behavior

| Mode | Self post (`submission_card.dart`) | Comment (`comments_tree.dart`) |
|---|---|---|
| HTML off (default) | `Text(self.text)` | `Text(comment.body)` |
| HTML on | `HtmlWidget(textHtml)` via `flutter_widget_from_html` | `HtmlWidget(comment.bodyHtml.trim())` |

So Flutter’s **shipped default is plain text of the markdown source** (markup characters like `**` visible). The HTML path is opt-in richer rendering, not the baseline.

Intent parity with “fix clear bugs” means iOS should not inherit “show raw `**`” as the product default if a SwiftUI-native path can render that markup correctly.

---

## What Reddit actually stores

From Reddit’s JSON wiki ([reddit-archive/reddit wiki — JSON](https://github.com/reddit-archive/reddit/wiki/JSON)):

- **`selftext` / `body`:** “the raw text… includes the raw markup characters such as `**` for bold”
- **`selftext_html` / `body_html`:** “the formatted HTML text as displayed on reddit… NOTE: The HTML string will be escaped. You must unescape to get the raw HTML” (with `raw_json=1`, Flutter already receives unescaped HTML entities)

So the canonical authoring format is **Markdown-ish markup**; HTML is a server-rendered companion, not the source of truth for editing.

---

## SwiftUI / Foundation options

### A. Plain `Text(string)` — reject as default

Matches Flutter’s default literally, but leaves Reddit markup unrendered. Fine as a **fallback**, not as the SPEC default.

### B. HTML → `NSAttributedString` → `AttributedString` → `Text` — reject as default

Apple documents HTML import on `NSAttributedString.init(data:options:documentAttributes:)`:

> Don’t call this method from a background thread if the options dictionary includes the documentType attribute with a value of html… The HTML import mechanism is meant for implementing something like markdown… **not for general HTML import.**

Source: [init(data:options:documentAttributes:)](https://developer.apple.com/documentation/foundation/nsattributedstring/init(data:options:documentattributes:))

`DocumentType.html` further notes Apple **discourages** the synchronous HTML importer and points at WebKit-based loaders for general HTML ([DocumentType.html](https://developer.apple.com/documentation/foundation/nsattributedstring/documenttype/html)).

Reddit’s HTML is full post/comment markup (lists, links, etc.), not a tiny style transfer payload — a poor fit for the importer Apple scopes to “something like markdown.”

### C. Markdown → `AttributedString` → `Text` — **choose this**

Foundation:

- [`AttributedString.init(markdown:options:baseURL:)`](https://developer.apple.com/documentation/foundation/attributedstring/init(markdown:options:baseurl:)-52n3u) — “Creates an attributed string from a Markdown-formatted string…”

SwiftUI:

- [`Text.init(_:)` for `AttributedString`](https://developer.apple.com/documentation/swiftui/text/init(_:)) — “Creates a text view that displays styled attributed content.” Docs explicitly show creating attributed content **with Markdown syntax** (bold / links) for `Text`.

This is the SwiftUI-native path Apple steers toward for constrained rich text — the same niche Reddit’s `selftext`/`body` occupy.

### D. `WKWebView` for HTML — reject as default

Heavier, not `Text`-native, fights list/scroll performance for feed cards and comment trees. Overkill for body copy.

---

## Caveats for the SPEC (not blockers)

1. **Reddit Markdown ≠ CommonMark / Apple Markdown.** Spoilers (`>!…!<`), superscript, some table/edge cases may not render identically to reddit.com. Acceptable for v1; plain-text fallback on throw covers hard failures.
2. **Links:** Markdown links become tappable via `Text`’s link attribute (per SwiftUI `Text` docs). Prefer opening in-app / Safari consistently with other lurkur link handling (behavior ticket territory).
3. **Models:** Keep fetching both markdown and HTML if useful later, but **render from `selftext`/`body` only** unless a future bug forces an exception.
4. **Comment image hack:** Flutter treats bodies starting with `https://preview.redd.it/` as images (`comments_tree.dart`). Preserve that special case separately from body rendering.

---

## Why this matches standing preferences

| Preference | How Markdown default satisfies it |
|---|---|
| No HTML toggle | One path; no settings surface |
| SwiftUI-native | `AttributedString` + `Text` |
| Intent parity / fix clear bugs | Renders the markup Reddit authors wrote, instead of Flutter’s default raw-source display or the fragile HTML importer |

---

## Sources

1. Flutter models/UI: `reddit_submission.dart`, `reddit_comment.dart`, `submission_card.dart`, `comments_tree.dart`, `preferences_cubit.dart`, `reddit_api.dart`, `pubspec.yaml` (`flutter_widget_from_html`)
2. [Reddit JSON wiki — comment/link `body` / `selftext` / `*_html`](https://github.com/reddit-archive/reddit/wiki/JSON)
3. [AttributedString.init(markdown:options:baseURL:)](https://developer.apple.com/documentation/foundation/attributedstring/init(markdown:options:baseurl:)-52n3u)
4. [Text.init(_ attributedContent:)](https://developer.apple.com/documentation/swiftui/text/init(_:))
5. [NSAttributedString.init(data:options:documentAttributes:)](https://developer.apple.com/documentation/foundation/nsattributedstring/init(data:options:documentattributes:)) — HTML importer limitations
6. [NSAttributedString.DocumentType.html](https://developer.apple.com/documentation/foundation/nsattributedstring/documenttype/html) — discourage sync HTML import
