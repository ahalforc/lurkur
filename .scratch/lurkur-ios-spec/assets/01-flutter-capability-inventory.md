# Flutter lurkur — user-visible capability inventory

Primary source: `apps/flutter/lib/` (features, blocs, widgets, Reddit models).  
Purpose: parity checklist for lurkur-ios. Dead / never-reachable-from-UI paths are listed at the end and **excluded** from required parity.

---

## 1. Navigation & shell

| Capability | Notes | Citations |
|---|---|---|
| Auth-gated routing (“sealed garden”) | Unauthorized → only sign-in; Authorized → tab shell | `app/blocs/router_cubit.dart`, `main.dart` (`_connectAuthToRoutes`) |
| Sign-in route `/` | `SignInPage` | `router_cubit.dart` `UnauthorizedRoutes`, `features/sign_in_page.dart` |
| Bottom nav: Home / Popular / Browse / Settings | Labels + icons; Settings opens popup (does **not** switch branch) | `app/widgets/shells.dart`, `router_cubit.dart` `AuthorizedRoutes` (index `3` → `showSettingsPopup`) |
| Home tab `/home` | `SubredditPage()` → user’s multi-home feed (`subreddit == null`) | `router_cubit.dart`, `features/subreddit_page.dart` |
| Popular tab `/popular` | `SubredditPage(subreddit: 'popular')` | `router_cubit.dart` |
| Browse tab `/browse` | `BrowsePage` | `router_cubit.dart`, `features/browse_page.dart` |
| Push subreddit `/subreddit?subreddit=` | From Browse text field or subscription tile | `router_cubit.dart` `pushSubreddit`, `browse_page.dart` |
| Back from pushed subreddit | Leading affordance when subreddit ∉ `{null, 'popular'}` | `subreddit_page.dart` `automaticallyImplyLeading` |
| Modal bottom sheets (“primary popup”) | Drag handle; half or ~90% height | `app/widgets/popups.dart` `showPrimaryPopup` |
| Confirmation dialog | Cancel / Confirm | `popups.dart` `showConfirmationPopup` |

---

## 2. Auth / session

| Capability | Notes | Citations |
|---|---|---|
| Cold-start token restore | Loading indicator while checking secure storage | `sign_in_page.dart`, `app/blocs/auth_cubit.dart` `initialize` |
| Sign in button → OAuth WebView sheet | Reddit authorize URL in in-app WebView; intercept redirect for `state` + `code` | `sign_in_page.dart` `_AuthWebView`, `auth_cubit.dart` `startAuthorizingViaWeb` / `completeAuthorizingViaWeb` |
| Persist access + refresh tokens | Secure storage; refresh when expired | `auth_cubit.dart` `_AuthStorage`, `_refreshAccessToken` |
| Log out | Clears tokens; returns to unauthorized routes | `features/settings_popup.dart` `_LogOut`, `auth_cubit.dart` `logout` |
| Branding on sign-in | Title “lurkur”, subtitle “Reddit, but simpler.” | `sign_in_page.dart` |

OAuth scopes requested include `mysubreddits read subscribe` (`auth_cubit.dart` `Authorizing.queryParams`), but **no subscribe/unsubscribe UI** exists.

---

## 3. Feeds (Home / Popular / Subreddit)

| Capability | Notes | Citations |
|---|---|---|
| Load submissions listing | Home = oauth root listing; else `/r/{name}/{sort}` | `app/blocs/reddit/subreddit_cubit.dart`, `app/reddit/api/reddit_api.dart` `getSubmissions` |
| Subreddit header image in app bar | From `/r/{name}/about` `mobile_banner_image`; not for home/popular | `subreddit_cubit.dart`, `reddit_subreddit.dart`, `subreddit_page.dart` |
| Sort options popup | hot; top of hour/day/week/month/year/all time; default **hot** | `subreddit_page.dart` `_showSortOptionsPopup`, `SortOption` in `subreddit_cubit.dart` |
| Refresh | Reloads + scrolls to top | `subreddit_page.dart` `_refresh` |
| Infinite scroll / load more | At ≥80% scroll extent | `subreddit_page.dart` `_maybeLoadMore`, `subreddit_cubit.dart` `loadMore` |
| Loading / failure indicators | Initial load and load-more failure | `subreddit_page.dart`, `app/widgets/indicators.dart` |
| Filter hidden subreddits from feed | Prefs-driven client filter | `subreddit_page.dart` + `preferences_cubit.dart` `hiddenSubreddits` |
| Tap submission → detail sheet | Expanded primary popup | `subreddit_page.dart` → `showSubmissionPopup` |
| Long-press submission → more actions | Compact primary popup | `subreddit_page.dart` → `showSubmissionMoreActionsPopup` |

---

## 4. Browse

| Capability | Notes | Citations |
|---|---|---|
| List subscribed subreddits | Sorted A–Z by display name | `browse_page.dart`, `browse_cubit.dart`, `reddit_api.dart` `getSubscriptions` |
| Subscription tile | Display name + title; tap → push subreddit | `browse_page.dart` `_SubscriptionTile` |
| Free-text “Go to a subreddit” | Submit → push that name | `browse_page.dart` `_SubredditTextField` |
| Refresh subscriptions | App bar refresh | `browse_page.dart` |

---

## 5. Submission card (feed + detail header)

Rendered by `features/subreddit/submission_card.dart`.

### Metadata always shown
- Subreddit + author (`_Context`)
- Title (`_Title`; density-dependent truncation)
- Tags: NSFW, pinned, stickied; score; comment count; relative created time (`_Info`, `app/widgets/tags.dart`)

### Density-driven preview (`PreferencesCubit.themeDensity`; compact feed only)
| Density | Feed behavior |
|---|---|
| **small** | Title max 1 line ellipsis; **thumbnail** only (no inline self/gallery/video) |
| **medium** | Full title; **thumbnail** only |
| **large** | Inline self text / gallery / video when present; no side thumbnail |

In submission detail popup, card uses `compact: false` → forced large-density preview.

### Content types (from `reddit_submission.dart` + card)
| Type | User-visible behavior | Citations |
|---|---|---|
| **Self text** | Plain text (fade, max 10 lines compact) or HTML via `HtmlWidget` if pref on | `submission_card.dart` `_SelfSubmission`, prefs `useHtmlForText` |
| **Gallery / images** | Horizontal snappable carousel; page indicator `n / N`; GIF + static from preview / media_metadata | `_GallerySubmission`, `app/widgets/images.dart` `Gallery` |
| **Video** | In-feed/detail player; aspect ratio from Reddit video metadata | `_VideoSubmission`, `app/widgets/videos.dart` |
| **Thumbnail** | 48×48 when not showing large preview | `images.dart` `Thumbnail` |
| **External / any URL link** | Not on card; shown as `LinkTile` in detail when `submission.link != null` | `reddit_submission.dart` `link`, `features/submission/link_tile.dart` |

Video player interactions (`videos.dart`):
- Preference **auto play videos**: play on load; pause/play when visibility ≷ 75%
- Tap play/pause; horizontal drag seek ±2.5% duration
- Circular progress + play/pause icon overlay

---

## 6. Submission detail popup

| Capability | Notes | Citations |
|---|---|---|
| Full submission card (non-compact) | Same media rules as large density | `features/submission_popup.dart` `SubmissionBody` |
| Link row | Opens URL in **in-app WebView** (`url_launcher`) | `link_tile.dart` |
| Comments tree | Load by subreddit + submission id | `CommentsCubit`, `reddit_api.dart` `getComments`, `features/submission/comments_tree.dart` |
| Expand / collapse threaded replies | `ExpansionTile`; left-padded children | `comments_tree.dart` |
| Comment author | Empty → “Deleted” | `comments_tree.dart` `_CommentTitle` |
| Comment score, OP tag, Edited tag | | `comments_tree.dart`, `tags.dart` |
| Comment body | Plain or HTML; special case: body starting with `https://preview.redd.it/` → inline image | `comments_tree.dart` `_CommentSubtitle` |
| Hide AutoModerator comments | Pref: skip rendering author `AutoModerator` | `comments_tree.dart`, prefs |

---

## 7. Submission more-actions popup

| Capability | Notes | Citations |
|---|---|---|
| Header with title + subreddit | | `features/submission_more_actions_popup.dart` |
| **Hide** | Adds submission’s subreddit to hidden list; dismisses sheet | `_ShowOrHide` → `preferences.hideSubreddit` |
| **Show json** | Nested sheet with selectable `submission.toString()` (indented raw JSON) | `_ShowJson` |

---

## 8. Settings popup

Opened from Settings nav item (`settings_popup.dart` via `router_cubit.dart`).

### Theme
| Setting | Behavior | Citations |
|---|---|---|
| **Brightness** | Cycles light → dark → auto (system) | `_ThemeBrightness`, `preferences_cubit.dart` `ThemeBrightness` |
| **Color** | Row is **visible but inert** (`onTap` omitted; faded) — see excluded | `_ThemeColor` |
| **Density** | Cycles small → medium → large (affects feed cards) | `_ThemeDensity`, `ThemeDensity` |

### Media
| Setting | Behavior | Citations |
|---|---|---|
| **Auto play videos** | Toggle | `_AutoPlayVideos` |
| **Use HTML for text** | Toggle; self + comment rendering | `_UseHtmlForText` |
| **Hide Auto Moderator comments** | Toggle | `_HideAutoModeratorComments` |

### Session
| Setting | Behavior | Citations |
|---|---|---|
| **Hidden subreddits** | Expandable list; uncheck/tap to unhide | `_HiddenSubreddits` |
| **Clear all settings** | Confirmation → wipe SharedPreferences | `_ClearAllSettings` |
| **Log Out** | | `_LogOut` |

Defaults (`PreferencesState.empty`): brightness auto, density large, autoPlayVideos true, useHtmlForText false, hideAutoModeratorComments false, hidden set empty.

---

## 9. Preferences persistence (user-visible effects)

Stored via `SharedPreferences` (`preferences_cubit.dart`):
- theme brightness, theme density, auto play videos, use HTML for text, hide AutoModerator, hidden subreddits
- theme color key exists in storage / connector to `ThemeCubit.setColorSeed`, but themes hardcode `seedColor: blueA` (`theme_cubit.dart`) and Color UI is inert → **no user-visible color effect**

---

## 10. Explicit non-capabilities (Flutter does not expose)

These are absent from UI (do not invent for “Flutter parity”):
- Vote / upvote / downvote
- Post or reply to comments
- Subscribe / unsubscribe (despite OAuth `subscribe` scope)
- Search beyond “go to subreddit by name”
- User profiles, inbox, awards, save, share-to-system (no share sheet)
- Multi-account
- Full-screen image viewer from gallery tap (`FullScreenImage` unused)

---

## Excluded: dead / unreachable from UI

| Item | Why excluded | Citations |
|---|---|---|
| `RouterCubit.pushDismissibleFullScreenWidget` | Defined, never called | `router_cubit.dart` |
| `FullScreenImage` | Widget defined, never referenced | `images.dart` |
| `showNotificationPopup` | Defined, never called | `popups.dart` |
| `PreferencesCubit.nextThemeColor` | Never invoked; Settings Color tile has no `onTap` | `preferences_cubit.dart`, `settings_popup.dart` `_ThemeColor` |
| Theme color seed → Material themes | Even if cycled, `ThemeState` light/dark ignore cubit color and use fixed `blueA` | `theme_cubit.dart` |

**Note for SPEC:** Map Notes already plan to drop theme color seeds and HTML-text toggle from iOS prefs; this inventory still records them as Flutter-visible (HTML toggle is live; Color is visible-but-inert).

---

## Parity checklist (condensed)

Use as lurkur-ios coverage targets (intent parity; chrome may differ):

- [ ] Unauthorized sign-in screen + OAuth in-app web flow + token restore/refresh/logout
- [ ] Tab shell: Home, Popular, Browse; Settings as modal surface
- [ ] Home / Popular / arbitrary subreddit feeds with sort, refresh, infinite scroll, loading/error
- [ ] Subreddit app-bar header image when available
- [ ] Browse: subscriptions list + go-to-subreddit by name
- [ ] Submission card metadata + density-aware previews (self / gallery-carousel / video / thumbnail)
- [ ] Video autoplay pref + play/pause + scrub-by-drag + visibility pause
- [ ] Submission detail: card + open link in-app + threaded comments (expand/collapse, OP/edited, HTML/plain, preview.redd.it images, hide AutoMod)
- [ ] Long-press actions: hide subreddit from feeds; show raw JSON (if kept)
- [ ] Prefs: brightness, density, autoplay videos, hide AutoMod, hidden-subreddit list + unhide, clear all
- [ ] (Flutter-present) Use HTML for text — product may omit per map Notes
- [ ] (Flutter-visible-inert) Theme color — product omits per map Notes
