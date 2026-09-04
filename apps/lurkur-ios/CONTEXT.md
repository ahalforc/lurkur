# lurkur-ios

Domain language for the iOS Reddit reader that replaces the legacy Flutter app.

## Language

**Feed**:
A scrollable listing of submissions for Home, Popular, or a named subreddit.
_Avoid_: Timeline, stream, subreddit page (when you mean the listing)

**Submission**:
A single Reddit post shown in a Feed or opened as Post detail.
_Avoid_: Post (as the data object), thread (as the submission itself)

**Post**:
The detail experience for one Submission: content, link, and comments.
_Avoid_: Submission detail popup, thread view

**Browse**:
The experience for listing subscriptions and jumping to a subreddit by name.
_Avoid_: Discover, search (unless you mean system search chrome)

**Core**:
Shared non-feature modules: Auth session, Reddit client/models, and Preferences store.
_Avoid_: Shared, common, utilities (as the package name)

**Feature package**:
A vertical slice under Features/ that owns that area’s views and feature state and must not import other feature packages.
_Avoid_: Module, screen folder (when you mean the package boundary)

**Preferences**:
Persisted reader settings (brightness, hide AutoMod, hidden subreddits)—not Reddit account prefs.
_Avoid_: Settings (when you mean the store rather than the Settings UI)
