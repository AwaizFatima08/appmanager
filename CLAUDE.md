# App Manager (HomiLabs) — project notes

Flutter Android app that lists every installed app with its size (app, data, cache), permissions and details,
and acts on them: open, uninstall (one or a batch), clear cache, change permissions. App id
`com.homilabs.appmanager` (locked after the first Play upload). Launcher name "App Manager". minSdk 26.

## Locations
- Code: `/mnt/storage/projects/appmanager` · GitHub `AwaizFatima08/appmanager` (PUBLIC repo: no secrets)
- Local backup: `/mnt/storage/project_backups/appmanager_backup`
- Backups: `bash scripts/backup.sh` (local copy + GitHub push; Drive layer off until `GDRIVE_FOLDER_ID` is set)
- Site: section on https://tools.homilabs.org (hub card `#appmanager`), privacy https://tools.homilabs.org/privacy#appmanager
  (use in Play Console), terms https://tools.homilabs.org/terms#appmanager. Source in `/mnt/storage/projects/homilabs_tools`
  (see its README). Update the privacy section before any release that changes what the app reads or adds ads/SDKs.

## What Android allows (the design follows this)
- Read: app list (`QUERY_ALL_PACKAGES`), permissions with granted state, sizes via `StorageStatsManager`, which
  needs the user to switch on **Usage access** (`PACKAGE_USAGE_STATS`). Without it the list shows a banner and no sizes.
- Uninstall: Android's own dialog (`REQUEST_DELETE_PACKAGES`); the user confirms each app. Pure system apps
  cannot be uninstalled; updated system apps get "Remove updates".
- Clear cache / change permissions of **another** app: not possible for a normal app. The app shows the steps,
  then opens that app's App info page. Doing it directly would need Shizuku or root (not built; Homi's call).
- Everything native is in `android/app/src/main/kotlin/com/homilabs/appmanager/AppManagerChannel.kt`
  (channel `com.homilabs.appmanager/apps`); Dart side `lib/features/apps/data/app_platform_service.dart`.
- Play: `QUERY_ALL_PACKAGES` needs the "device management / app manager" declaration in Play Console.

## Ads
AdMob account homilabs.smc@gmail.com (publisher pub-2087846699268567). Config in `config/admob.json` (app and
units created 9 Nov 2026; app "Requires review" until the Play listing is linked). Debug builds use Google's test units.
Banner under the app list only; interstitial after a batch uninstall report, 5 minutes apart; never on the detail
screen. UMP consent before the SDK starts. `bash scripts/check-release-ad-ids.sh` must pass before a release build.

## Release
- Upload key `.secrets/appmanager-upload.keystore` (gitignored; `android/key.properties` points at it). Release
  builds are unsigned without it, never debug-signed.
- Build: `jobq run --name appmanager-release-aab -- bash -c 'flutter build appbundle --release --obfuscate
  --split-debug-info=build/symbols && cd android && ./gradlew --stop'`, then copy the bundle and zipped symbols to
  `releases/v<version>-<build>/` (gitignored). Bump `version:` in pubspec before every new upload.
- Play Console notes (listing, declarations, Data safety, status): `docs/play-store.md`. Icon source `assets/branding/`.
- 1.0.0 (build 1) sent for Play review 9 Nov 2026. After approval: AdMob → App Manager → "Add store" to link the listing.

## Gate before commit
```
dart format --set-exit-if-changed lib test
flutter analyze
flutter test
```
Heavy jobs follow `~/.claude/heavy-jobs.md`: use `jobq`, then `./gradlew --stop`.
