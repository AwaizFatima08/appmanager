import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'gen/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[Locale('en')];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'App Manager'**
  String get appTitle;

  /// No description provided for @loadError.
  ///
  /// In en, this message translates to:
  /// **'Could not read the apps on this phone ({code}).'**
  String loadError(String code);

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get retry;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search apps'**
  String get searchHint;

  /// No description provided for @clearSearch.
  ///
  /// In en, this message translates to:
  /// **'Clear search'**
  String get clearSearch;

  /// No description provided for @scopeUser.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get scopeUser;

  /// No description provided for @scopeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get scopeSystem;

  /// No description provided for @scopeAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get scopeAll;

  /// No description provided for @sortLabel.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sortLabel;

  /// No description provided for @sortName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get sortName;

  /// No description provided for @sortTotalSize.
  ///
  /// In en, this message translates to:
  /// **'Largest first'**
  String get sortTotalSize;

  /// No description provided for @sortCacheSize.
  ///
  /// In en, this message translates to:
  /// **'Most cache first'**
  String get sortCacheSize;

  /// No description provided for @sortRecentlyUpdated.
  ///
  /// In en, this message translates to:
  /// **'Recently updated'**
  String get sortRecentlyUpdated;

  /// No description provided for @sortNeedsAccess.
  ///
  /// In en, this message translates to:
  /// **'Sizes need usage access'**
  String get sortNeedsAccess;

  /// No description provided for @totalsLine.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 app} other{{count} apps}} · {total} · cache {cache}'**
  String totalsLine(int count, String total, String cache);

  /// No description provided for @totalsCountOnly.
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 app} other{{count} apps}}'**
  String totalsCountOnly(int count);

  /// No description provided for @noApps.
  ///
  /// In en, this message translates to:
  /// **'No apps match.'**
  String get noApps;

  /// No description provided for @usageAccessTitle.
  ///
  /// In en, this message translates to:
  /// **'See each app\'s size'**
  String get usageAccessTitle;

  /// No description provided for @usageAccessBody.
  ///
  /// In en, this message translates to:
  /// **'Allow Usage access. Sizes only; nothing leaves your phone.'**
  String get usageAccessBody;

  /// No description provided for @usageAccessButton.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get usageAccessButton;

  /// No description provided for @settingsUnavailable.
  ///
  /// In en, this message translates to:
  /// **'This phone did not open the settings screen.'**
  String get settingsUnavailable;

  /// No description provided for @badgeSystem.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get badgeSystem;

  /// No description provided for @badgeDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get badgeDisabled;

  /// No description provided for @versionLine.
  ///
  /// In en, this message translates to:
  /// **'Version {version}'**
  String versionLine(String version);

  /// No description provided for @selectedCount.
  ///
  /// In en, this message translates to:
  /// **'{count} selected'**
  String selectedCount(int count);

  /// No description provided for @selectAll.
  ///
  /// In en, this message translates to:
  /// **'Select all shown'**
  String get selectAll;

  /// No description provided for @cancelSelection.
  ///
  /// In en, this message translates to:
  /// **'Cancel selection'**
  String get cancelSelection;

  /// No description provided for @uninstallSelected.
  ///
  /// In en, this message translates to:
  /// **'Uninstall selected'**
  String get uninstallSelected;

  /// No description provided for @batchConfirmTitle.
  ///
  /// In en, this message translates to:
  /// **'Uninstall {count, plural, =1{1 app} other{{count} apps}}?'**
  String batchConfirmTitle(int count);

  /// No description provided for @batchConfirmBody.
  ///
  /// In en, this message translates to:
  /// **'Android asks you to confirm each app. System apps in the selection are skipped.'**
  String get batchConfirmBody;

  /// No description provided for @batchConfirmGo.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get batchConfirmGo;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @batchReport.
  ///
  /// In en, this message translates to:
  /// **'Uninstalled {removed} of {requested}.'**
  String batchReport(int removed, int requested);

  /// No description provided for @openApp.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get openApp;

  /// No description provided for @uninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get uninstall;

  /// No description provided for @uninstallUpdates.
  ///
  /// In en, this message translates to:
  /// **'Remove updates'**
  String get uninstallUpdates;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'App info'**
  String get appInfo;

  /// No description provided for @uninstalled.
  ///
  /// In en, this message translates to:
  /// **'{label} was uninstalled.'**
  String uninstalled(String label);

  /// No description provided for @uninstallFailed.
  ///
  /// In en, this message translates to:
  /// **'Android could not start the uninstall.'**
  String get uninstallFailed;

  /// No description provided for @appGone.
  ///
  /// In en, this message translates to:
  /// **'This app is no longer installed.'**
  String get appGone;

  /// No description provided for @systemAppNote.
  ///
  /// In en, this message translates to:
  /// **'Built into the phone. It cannot be uninstalled, but you can disable it in App info.'**
  String get systemAppNote;

  /// No description provided for @storageTitle.
  ///
  /// In en, this message translates to:
  /// **'Storage'**
  String get storageTitle;

  /// No description provided for @storageApp.
  ///
  /// In en, this message translates to:
  /// **'App'**
  String get storageApp;

  /// No description provided for @storageData.
  ///
  /// In en, this message translates to:
  /// **'User data'**
  String get storageData;

  /// No description provided for @storageCache.
  ///
  /// In en, this message translates to:
  /// **'Cache'**
  String get storageCache;

  /// No description provided for @storageTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get storageTotal;

  /// No description provided for @storageNoAccess.
  ///
  /// In en, this message translates to:
  /// **'Allow usage access to see this app\'s size.'**
  String get storageNoAccess;

  /// No description provided for @clearCache.
  ///
  /// In en, this message translates to:
  /// **'Clear cache'**
  String get clearCache;

  /// No description provided for @clearCacheSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Clear the cache in Android\'s settings'**
  String get clearCacheSheetTitle;

  /// No description provided for @clearCacheSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Android lets only its own settings clear another app\'s cache. App Manager opens the right page for you.'**
  String get clearCacheSheetBody;

  /// No description provided for @clearCacheStep1.
  ///
  /// In en, this message translates to:
  /// **'Tap Storage & cache (or Storage).'**
  String get clearCacheStep1;

  /// No description provided for @clearCacheStep2.
  ///
  /// In en, this message translates to:
  /// **'Tap Clear cache.'**
  String get clearCacheStep2;

  /// No description provided for @clearCacheStep3.
  ///
  /// In en, this message translates to:
  /// **'Come back here: the new size shows up.'**
  String get clearCacheStep3;

  /// No description provided for @permissionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Permissions'**
  String get permissionsTitle;

  /// No description provided for @permissionsAllowed.
  ///
  /// In en, this message translates to:
  /// **'Allowed'**
  String get permissionsAllowed;

  /// No description provided for @permissionsDenied.
  ///
  /// In en, this message translates to:
  /// **'Not allowed'**
  String get permissionsDenied;

  /// No description provided for @permissionsSpecial.
  ///
  /// In en, this message translates to:
  /// **'Special access'**
  String get permissionsSpecial;

  /// No description provided for @permissionsFixed.
  ///
  /// In en, this message translates to:
  /// **'Granted at install ({count})'**
  String permissionsFixed(int count);

  /// No description provided for @permissionsNone.
  ///
  /// In en, this message translates to:
  /// **'This app asks for no permissions.'**
  String get permissionsNone;

  /// No description provided for @permissionsFixedNote.
  ///
  /// In en, this message translates to:
  /// **'Android grants these when the app is installed. They cannot be switched off.'**
  String get permissionsFixedNote;

  /// No description provided for @permissionsError.
  ///
  /// In en, this message translates to:
  /// **'Could not read this app\'s permissions.'**
  String get permissionsError;

  /// No description provided for @changePermissions.
  ///
  /// In en, this message translates to:
  /// **'Change permissions'**
  String get changePermissions;

  /// No description provided for @permissionsSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'Change permissions in Android\'s settings'**
  String get permissionsSheetTitle;

  /// No description provided for @permissionsSheetBody.
  ///
  /// In en, this message translates to:
  /// **'Only Android\'s settings can allow or deny another app\'s permissions. App Manager opens the right page for you.'**
  String get permissionsSheetBody;

  /// No description provided for @permissionsStep1.
  ///
  /// In en, this message translates to:
  /// **'Tap Permissions.'**
  String get permissionsStep1;

  /// No description provided for @permissionsStep2.
  ///
  /// In en, this message translates to:
  /// **'Pick a permission and choose Allow or Don\'t allow.'**
  String get permissionsStep2;

  /// No description provided for @permissionsStep3.
  ///
  /// In en, this message translates to:
  /// **'Come back here: the list updates.'**
  String get permissionsStep3;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open settings'**
  String get openSettings;

  /// No description provided for @detailsTitle.
  ///
  /// In en, this message translates to:
  /// **'Details'**
  String get detailsTitle;

  /// No description provided for @detailPackage.
  ///
  /// In en, this message translates to:
  /// **'Package'**
  String get detailPackage;

  /// No description provided for @detailInstalled.
  ///
  /// In en, this message translates to:
  /// **'Installed'**
  String get detailInstalled;

  /// No description provided for @detailUpdated.
  ///
  /// In en, this message translates to:
  /// **'Updated'**
  String get detailUpdated;

  /// No description provided for @detailTargetSdk.
  ///
  /// In en, this message translates to:
  /// **'Target Android API'**
  String get detailTargetSdk;

  /// No description provided for @detailMinSdk.
  ///
  /// In en, this message translates to:
  /// **'Minimum Android API'**
  String get detailMinSdk;

  /// No description provided for @detailInstaller.
  ///
  /// In en, this message translates to:
  /// **'Installed from'**
  String get detailInstaller;

  /// No description provided for @detailInstallerUnknown.
  ///
  /// In en, this message translates to:
  /// **'Unknown (sideloaded or preinstalled)'**
  String get detailInstallerUnknown;

  /// No description provided for @detailStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get detailStatus;

  /// No description provided for @statusEnabled.
  ///
  /// In en, this message translates to:
  /// **'Enabled'**
  String get statusEnabled;

  /// No description provided for @statusDisabled.
  ///
  /// In en, this message translates to:
  /// **'Disabled'**
  String get statusDisabled;

  /// No description provided for @privacyChoices.
  ///
  /// In en, this message translates to:
  /// **'Privacy choices'**
  String get privacyChoices;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @aboutBody.
  ///
  /// In en, this message translates to:
  /// **'App Manager by HomiLabs lists the apps on your phone with their size and permissions, and takes you straight to uninstalling them, clearing their cache or changing their permissions. Everything stays on your phone.'**
  String get aboutBody;

  /// No description provided for @cacheValue.
  ///
  /// In en, this message translates to:
  /// **'{size} cache'**
  String cacheValue(String size);
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
