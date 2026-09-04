# 03 — How should SwiftUI render Reddit post and comment bodies?

**Type:** research  
**Status:** resolved  
**Blocked by:** None — can start immediately

## Question

Flutter optionally rendered HTML for selftext/comments. The iOS SPEC will have **no HTML toggle**. What is the best default SwiftUI approach for Reddit body/comment content (plain text, AttributedString from HTML, Markdown, etc.)? Prefer primary Apple/docs + what Reddit actually returns in Flutter’s models. Recommend one default for the SPEC.

## Answer

**Default: Markdown via `AttributedString(markdown:)` → SwiftUI `Text`, using Reddit `selftext` / `body` (not HTML).** Fall back to plain `Text` if parsing throws. Do not ship an HTML toggle.

Reddit’s JSON treats those fields as markup source and `*_html` as a rendered companion; Flutter’s default is already non-HTML plain text of that source. Apple’s SwiftUI/`AttributedString` Markdown path is first-class; the HTML `NSAttributedString` importer is explicitly not for general HTML.

Full write-up: [assets/03-reddit-content-rendering.md](../assets/03-reddit-content-rendering.md)
