# Play Console — App Manager

Notes for the first upload. Package `com.homilabs.appmanager` (cannot change after the first upload).

## Release files
- Bundle: `releases/v<version>/app-release.aab` (signed with the upload key below).
- Symbols for crash stack traces: `releases/v<version>/symbols.zip` (Play Console → App bundle explorer →
  Downloads → upload as "native debug symbols" is not needed; keep it to de-obfuscate Dart traces with
  `flutter symbolize`).
- Store icon: `store/play-icon-512.png` (512×512, from `assets/branding/icon_square.svg`).
- Feature graphic `store/feature-graphic.png` (from `assets/branding/feature_graphic.svg`); phone screenshots
  `store/screenshots/` (1080×1920, 9:16 — Play rejects 1:2). QUERY_ALL_PACKAGES review video
  `store/video/review.mp4`, hosted at https://tools.homilabs.org/appmanager/review.mp4 (uploaded by scp, not in the
  homilabs_tools repo; keep it online while Play may re-review the declaration).

## Status
- 9 Nov 2026: Play app "App Manager: Size & Uninstall" created (organization account Homilabs, app id
  4976197179365239109). All App content declarations, listing, store settings (Tools, homilabs.smc@gmail.com,
  https://tools.homilabs.org) and the QUERY_ALL_PACKAGES declaration done. Production release 1 (1.0.0) in 178
  countries sent for review; managed publishing off, so it goes live on approval.

## Signing
- Upload key: `.secrets/appmanager-upload.keystore`, alias `appmanager-upload` (gitignored; password in
  `.secrets/appmanager-upload-keystore-credentials.txt`). `android/key.properties` points Gradle at it.
- Keep Play App Signing on (default). Losing the upload key is recoverable through Play support;
  keep the `.secrets/` folder in the local backup.
- Upload certificate SHA-256:
  `E5:27:7B:7D:1E:B7:A9:86:8C:B8:06:84:B4:81:68:27:1B:C7:75:80:A6:9E:3C:92:58:7F:D2:75:9B:D1:C6:F6`

## Listing
- App name: App Manager: Size & Uninstall
- Short description (≤80): See every app's size and permissions, then uninstall or clean up in a tap.
- Full description:

  App Manager shows every app on your phone in one simple list, with how much space each one takes and which
  permissions it has.

  • Sort apps by size, cache, name or last update, and search by name.
  • See each app's size split into app, user data and cache.
  • See which permissions an app has been allowed or denied.
  • Uninstall one app, or select several and uninstall them in one go. Android asks you to confirm each one.
  • Clear an app's cache or change its permissions: App Manager shows the steps and opens that app's settings page.

  Sizes need Usage access, which you switch on once in Android settings. App Manager only reads sizes with it.
  Nothing you see in App Manager leaves your phone.

- Category: Tools. Contact email: homilabs.smc@gmail.com.
- Privacy policy: https://tools.homilabs.org/privacy#appmanager

## App content (declarations)
- **Ads**: yes (AdMob banner and interstitial).
- **Advertising ID**: yes, used for advertising (added by the Google Mobile Ads SDK).
- **QUERY_ALL_PACKAGES**: core purpose is managing installed apps — listing them with size and permissions and
  uninstalling them. Pick the app-management / device-management use; the app cannot work without seeing all
  installed apps. A short screen recording of the list and an uninstall helps the review.
- **Usage access (PACKAGE_USAGE_STATS)**: no Play form; the app explains it in the banner before sending the user to
  settings, and uses it only for `StorageStatsManager` sizes.
- **Target audience**: 18+ (not designed for children).
- **Content rating**: IARC "All other app types", every question "No" (no violence, user content, gambling or
  location sharing) → Everyone / PEGI 3 / 3+.
- **Data safety** (the app itself collects nothing; answers cover the AdMob SDK):
  - Data collected: Device or other IDs (advertising ID); App activity / app interactions; App info and
    performance (crash logs, diagnostics); Approximate location (from IP). Purpose: Advertising or marketing,
    Analytics, Fraud prevention. Shared with Google (AdMob).
  - Encrypted in transit: yes. Users can request deletion: no (nothing stored by HomiLabs; Google's own controls apply).
  - The installed-app list, sizes and permissions are processed on the device only and are not collected.

## After the listing is live
- AdMob → Apps → App Manager → "Add store" to link the Play listing (app is "Requires review" until then).
