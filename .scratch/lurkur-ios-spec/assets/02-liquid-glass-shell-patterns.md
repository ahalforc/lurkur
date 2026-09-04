# Liquid Glass / latest-iOS shell patterns for lurkur-ios

**Ticket:** [What do Liquid Glass / latest-iOS shell patterns imply for this app?](../issues/02-liquid-glass-shell-patterns.md)  
**Question:** Against Apple’s primary docs for the newest iOS, what does a Liquid Glass–era `TabView` / Settings presentation imply for a multi-tab Reddit reader that keeps Home, Popular, Browse, and Settings?

**Standing preferences in scope:** newest OS only / Liquid Glass; keep Home / Popular / Browse + Settings IA; iPhone + iPad (Mac out of scope); SwiftUI-native chrome.

---

## Verdict (short)

Liquid Glass does **not** force an IA change to Home / Popular / Browse / Settings. A four-tab `TabView` with Settings as a peer tab is explicitly compatible with Apple’s guidance. “Newest OS only” means ship against the **iOS 26 / iPadOS 26 SDK** with deployment target matching that release, accept automatic glass chrome on system bars, and **do not** use the temporary UI-compatibility opt-out. Chrome should be system `Tab` / `TabView` + per-tab `NavigationStack`, floating glass tab bar, optional minimize-on-scroll on iPhone, grouped `Form` for Settings content, and no custom Material-style bars.

---

## Deployment-target consequences of “newest OS only”

| Implication | Why (Apple source) |
|---|---|
| Treat **iOS 26 / iPadOS 26** as the floor (deployment target + run target). | Liquid Glass and the shell APIs below are introduced with that release; e.g. `TabBarMinimizeBehavior.onScrollDown` is available on iOS 26.0+ / iPadOS 26.0+ ([docs](https://developer.apple.com/documentation/swiftui/tabbarminimizebehavior/onscrolldown)). |
| Build with the **latest SDK (Xcode 26)** so standard SwiftUI structure picks up Liquid Glass automatically. | [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass): rebuild with latest SDKs; standard bars, sheets, popovers, and controls adopt the material with minimal code. WWDC25 *Build a SwiftUI app with the new design* ([session 323](https://developer.apple.com/videos/play/wwdc2025/323/)): building with Xcode 26 SDKs surfaces structural updates to `TabView`, toolbars, search, sheets. |
| Do **not** set `UIDesignRequiresCompatibility` to keep the pre–Liquid Glass look. | Apple documents this Info key as a **temporary** compatibility mode while reviewing UI; absence/`NO` is the default for apps linking the latest SDKs; the key is ignored when building for iOS 27+ ([UIDesignRequiresCompatibility](https://developer.apple.com/documentation/bundleresources/information-property-list/uidesignrequirescompatibility)). Newest-OS-only + Liquid Glass preference = opt into the new design, not delay it. |
| Newer shell modifiers are newest-OS APIs, not back-deployable polish. | Examples: `.tabBarMinimizeBehavior(_:)`, `.tabViewBottomAccessory`, `Tab(role: .search)`, floating glass tab/sidebar behavior — all part of the iOS 26 design system described in Adopting Liquid Glass and WWDC25 323. |
| Accessibility / user Liquid Glass preferences are system-owned if you stay on standard components. | Adopting Liquid Glass: people can choose a preferred Liquid Glass look or enable Reduce Transparency / Reduce Motion; standard framework components adapt automatically — test custom chrome against those settings. |

**Practical SPEC consequence:** the app can assume Liquid Glass chrome and iOS 26-only APIs everywhere in the shell. No dual-chrome story, no “old tab bar” branch, no Flutter visual parity layer for bars.

---

## Recommended chrome patterns

### 1. Navigation layer vs content layer

Apple draws a hard line: Liquid Glass is for the **topmost navigation/control layer**; content stays underneath and should remain the focus.

- [Adopting Liquid Glass — Navigation](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass): tab bars and sidebars float in the Liquid Glass layer; keep a clear separation between navigation and content.
- [HIG — Materials](https://developer.apple.com/design/human-interface-guidelines/materials): Liquid Glass unifies controls/navigation without obscuring content; **standard materials** (not Liquid Glass) belong in the content layer for differentiation.
- [HIG — Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars): a tab bar floats above content; items rest on a Liquid Glass background so content can peek through.

**For lurkur:** feed lists, post detail, browse lists are content. Do not glass-wrap cards, list rows, or entire screens. Prefer system scroll-edge behavior under bars; remove custom bar backgrounds that fight the effect (Adopting Liquid Glass: reduce custom backgrounds on tab bars / toolbars / split views / sheets).

### 2. Top-level shell = system `TabView` + `Tab`

- Tab bars are for **persistent top-level sections**, preserving per-section navigation state ([HIG Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars); WWDC25 323).
- Prefer fewer tabs; avoid the overflow **More** tab ([HIG Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars)). Four destinations (Home, Popular, Browse, Settings) sits comfortably under the “five or fewer default tabs” customization guidance.
- Use a tab bar for **navigation, not actions** (HIG Tab bars). Feed actions belong in toolbars / swipe actions / sheets, not extra tabs.
- Each tab should own its own `NavigationStack` (standard SwiftUI structure; avoids cross-tab stack bugs and matches Apple sample patterns in WWDC material).

**iPhone:** floating bottom tab bar; content should extend under it with correct safe-area / scroll insets so posts peek through glass.

**Minimize on scroll (optional but recommended for feed tabs):**

```swift
TabView { /* … */ }
.tabBarMinimizeBehavior(.onScrollDown)
```

Documented in [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass) and WWDC25 323; `.onScrollDown` minimizes only on **iPhone** ([docs](https://developer.apple.com/documentation/swiftui/tabbarminimizebehavior/onscrolldown)). Good fit for long Reddit feeds; Settings forms may not need it.

**Bottom accessory:** `.tabViewBottomAccessory` is for persistent controls (e.g. media mini-player). No lurkur v1 need unless a later feature requires always-on chrome above the tab bar (WWDC25 323).

### 3. iPad: same tab shell, optional sidebar adaptivity

Standing map note: same tab shell, larger canvas — **no split-view requirement** in v1 SPEC.

Apple still recommends considering `.tabViewStyle(.sidebarAdaptable)` so the tab bar can adapt into a sidebar on iPad ([Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass); [HIG Tab bars / Sidebars](https://developer.apple.com/design/human-interface-guidelines/tab-bars); `defaultAdaptableTabBarPlacement` is iPadOS-only for that style).

**Implication for SPEC (not an IA rename):**

- v1 can stay **tab-bar-first** on iPad (aligned with standing preference).
- `sidebarAdaptable` is an **allowed enhancement**, not required to keep Home / Popular / Browse / Settings.
- Do not require `NavigationSplitView` app-wide for v1; if Browse later needs a primary/detail split *inside* a tab, that is secondary navigation within the tab (HIG: sidebar-within-tab must not change which top-level tab is selected).

### 4. Toolbars and sheets

- Toolbars float on Liquid Glass; prefer monochrome icons; remove extra backgrounds behind bars; use `ToolbarSpacer` to group related actions (WWDC25 323; Adopting Liquid Glass — Menus and toolbars).
- Partial-height sheets are inset with Liquid Glass; avoid custom `presentationBackground` unless necessary (WWDC25 323; Adopting Liquid Glass — Windows and modals).
- Lists/forms gain larger row height, padding, and corner radius; use title-style section headers; prefer SwiftUI `Form` with grouped style (Adopting Liquid Glass — Organization and layout).

### 5. Settings presentation

Apple’s platform guidance ([Adding a settings interface to your app](https://developer.apple.com/documentation/foundation/adding-a-settings-interface-to-your-app)):

- There is **no** single standard Settings surface on iOS/iPadOS (unlike macOS `Settings` scene).
- If people change settings **occasionally**, “an app with a tab bar interface might add a **tab for settings**.”
- Frequent → always available from main UI; infrequent → system Settings app via Settings bundle.

SwiftUI’s `Settings { }` scene is documented for **macOS** ([Settings](https://developer.apple.com/documentation/swiftui/settings)) — out of scope here.

**Recommended pattern for lurkur (fits Apple + standing IA):**

1. **Settings as a fourth top-level `Tab`** (peer to Home / Popular / Browse).
2. Settings root = grouped `Form` / list inside that tab’s `NavigationStack` (Liquid Glass–era form metrics).
3. Prefer **in-app** settings for reader prefs people change occasionally (density, autoplay, etc.), not a Settings.bundle-only experience.
4. Sheet/modal Settings is a valid alternate for “as needed,” but is **not required** by Liquid Glass and fights the standing “Settings is part of the shell IA” preference. Leave exact tab-vs-sheet lock to ticket 07; research says **tab is first-class and sufficient**.

### 6. Search vs Browse (chrome role, not rename)

If search is a top-level tab, Apple wants the semantic search role so the system separates it and places it trailing:

```swift
Tab(role: .search) { /* … */ }
```

([Adopting Liquid Glass — Search](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass); WWDC25 323: search tab replaces the tab bar with the search field.)

**For lurkur:** Home / Popular / Browse are not named Search. Only apply `Tab(role: .search)` if Browse (or another tab) is truly the app-wide search page. Otherwise keep a normal tab and put `.searchable` on the relevant stack. This is a chrome-role decision, not a forced IA rename.

---

## Would anything force IA changes?

| Pressure | Forces IA change? | Notes |
|---|---|---|
| Liquid Glass floating tab bar | **No** | Visual/behavioral chrome only; same four destinations. |
| Tab count / More overflow | **No** | Four tabs is within HIG comfort; no need to merge Home+Popular. |
| Settings as tab | **No** | Apple cites tab-for-settings as the “occasionally” pattern. |
| macOS `Settings` scene | **N/A** | Mac out of scope. |
| System Settings bundle only | **No** | Wrong fit for prefs people tweak while reading; would *remove* in-app Settings, which standing prefs reject. |
| `sidebarAdaptable` on iPad | **No** | Same tabs; optional presentation morph. |
| `Tab(role: .search)` | **Only if** Browse is search | Would affect trailing placement / search morph UI, not the four-name IA unless you rename Browse → Search. |
| Minimize-on-scroll | **No** | iPhone feed UX only. |
| Avoid custom Liquid Glass everywhere | **No** | Constrains implementation (don’t glass the content), not tab names. |
| Clear navigation hierarchy | **No** | Reinforces keeping Settings/chrome out of the feed content layer (e.g. don’t bury all prefs only inside a post toolbar). |

**Bottom line:** Apple’s newest-OS docs **validate** keeping Home / Popular / Browse / Settings as a four-tab shell. Nothing in Liquid Glass requires collapsing feeds, moving Settings exclusively to a sheet or system Settings, or cloning Flutter/Material chrome.

---

## Spec-facing recommendations (handoff to ticket 07)

1. Deployment: **iOS 26 / iPadOS 26 only**; latest SDK; no `UIDesignRequiresCompatibility`.
2. Shell: SwiftUI `TabView` with four `Tab`s — Home, Popular, Browse, Settings — each with its own `NavigationStack`.
3. Chrome: system Liquid Glass tab bar/toolbars; no custom tab-bar backgrounds; feeds scroll under the floating bar.
4. iPhone: consider `.tabBarMinimizeBehavior(.onScrollDown)` on feed-heavy tabs.
5. iPad: same four tabs; `sidebarAdaptable` optional; no required app-wide split view for v1.
6. Settings: in-app Settings **tab** + grouped `Form`; not macOS `Settings` scene; not Settings-bundle-only.
7. Search role: use `Tab(role: .search)` only if a tab is actually app search; don’t force-rename Browse.
8. Do not apply Liquid Glass as a decorative content material.

---

## Primary sources

1. [Adopting Liquid Glass](https://developer.apple.com/documentation/technologyoverviews/adopting-liquid-glass) — Apple Developer Documentation (Technology Overviews).
2. [UIDesignRequiresCompatibility](https://developer.apple.com/documentation/bundleresources/information-property-list/uidesignrequirescompatibility) — Bundle Resources / Information Property List.
3. [Tab bars](https://developer.apple.com/design/human-interface-guidelines/tab-bars) — Human Interface Guidelines.
4. [Materials](https://developer.apple.com/design/human-interface-guidelines/materials) — Human Interface Guidelines (Liquid Glass vs standard materials).
5. [Sidebars](https://developer.apple.com/design/human-interface-guidelines/sidebars) — Human Interface Guidelines (tab ↔ sidebar).
6. [Adding a settings interface to your app](https://developer.apple.com/documentation/foundation/adding-a-settings-interface-to-your-app) — Foundation.
7. [Settings (SwiftUI scene)](https://developer.apple.com/documentation/swiftui/settings) — macOS settings scene (explicitly not the iOS pattern).
8. [TabBarMinimizeBehavior.onScrollDown](https://developer.apple.com/documentation/swiftui/tabbarminimizebehavior/onscrolldown) — SwiftUI (iOS 26+; minimize on iPhone only).
9. [defaultAdaptableTabBarPlacement(_:)](https://developer.apple.com/documentation/swiftui/view/defaultadaptabletabbarplacement(_:)) — SwiftUI (`sidebarAdaptable` on iPadOS).
10. WWDC25: [Build a SwiftUI app with the new design](https://developer.apple.com/videos/play/wwdc2025/323/) — TabView float/minimize/accessory, sheets, toolbars, search-tab patterns.
11. WWDC25: [Build a UIKit app with the new design](https://developer.apple.com/videos/play/wwdc2025/284/) — parallel UIKit tab/split Liquid Glass behavior (confirms platform chrome expectations).
