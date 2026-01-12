# Twitch App Agent Notes

## What’s implemented
- **SwiftUI macOS app (SwiftPM)** embedding Twitch via `WKWebView` with a glass UI.
- **App build script** packages `.app` and adds icon, signing, quarantine removal: `Scripts/make_app.sh`.
- **Sidebar** with native search, Explore links, Following Live list, and account/profile section.
- **Background loader** preloads `https://www.twitch.tv/following` so Following Live can populate without manual navigation.
- **UI restyling** via injected CSS/JS to hide Twitch top nav + left nav and soften cards/player for native feel.

## Key files
- `Sources/Twitch/App.swift` – main app scene.
- `Sources/Twitch/ContentView.swift` – sidebar layout, account section, logo header.
- `Sources/Twitch/WebViewStore.swift` – WKWebView config, CSS/JS injection, following live scraper, profile scraper.
- `Scripts/make_app.sh` – builds `.app`, sets Info.plist, copies icon, ad‑hoc codesign, clears quarantine.
- `Resources/AppIcon.icns` – app icon bundle.
- `Resources/sidebar_logo.png` – sidebar logo (local asset).

## Current UX behavior
- **Top nav + left nav** on Twitch web are hidden via injected CSS.
- **Glass styling** applies to Twitch cards and player controls.
- **Following Live** tries to parse from:
  - `/following` or `/directory/following` page cards
  - Twitch side nav (if available)
- **Profile info** is scraped from the web session and shown in the sidebar (avatar/name + actions).
- **Autoplay** is attempted once with a short retry to avoid loop.

## Build/Run
- Build: `./Scripts/make_app.sh`
- Output: `Build/Twitch.app`

## Notes / caveats
- Twitch DOM changes may break CSS/JS selectors.
- Following Live relies on DOM scraping; if it fails, update selectors in `WebViewStore.swift`.
- User agent is set to Safari‑like to reduce Twitch playback errors (#3000).

## Pending issues
- Following Live sometimes still shows placeholder text; adjust scraper in `WebViewStore.swift`.
- Stream autoplay may still fail for some channels; can add smarter play detection.
