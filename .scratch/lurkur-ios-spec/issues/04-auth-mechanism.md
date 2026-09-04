# 04 — Which auth mechanism should lurkur-ios use?

**Type:** grilling  
**Status:** resolved  
**Blocked by:** None — can start immediately

## Question

Auth is reopenable. Should lurkur-ios keep the current WKWebView + redirect intercept flow, move to `ASWebAuthenticationSession` (or another system API), or another shape — given installed-app OAuth, redirect URI `https://www.reddit.com`, Keychain persistence, and iPhone/iPad? Lock the approach the SPEC will require.

## Answer

**Keep WKWebView + redirect intercept** (do not move to `ASWebAuthenticationSession` for this SPEC).

- **Redirect URI:** `https://www.reddit.com` (intercept navigations that match this prefix for `state` + `code`)
- **Authorize:** `https://old.reddit.com/api/v1/authorize`
- **Scopes:** `mysubreddits read subscribe`
- **Token exchange / refresh:** `POST https://www.reddit.com/api/v1/access_token`; treat `expires_in` as seconds
- **Persistence:** Keychain keys for access token, refresh token, expiration; accessibility `AfterFirstUnlockThisDeviceOnly`; restore on launch; refresh when expired; logout clears all; Keychain write failure fails the exchange
- **UX:** Sign-in opens a sheet with non-ephemeral WKWebView; cancel → unauthorized without clearing stored tokens; success → authorized

SPEC must document this full auth contract (not a one-liner). ASWebAuth deferred: it would require changing Reddit’s redirect URI to a custom scheme or a domain we control.
