// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'App Manager';

  @override
  String loadError(String code) {
    return 'Could not read the apps on this phone ($code).';
  }

  @override
  String get retry => 'Try again';

  @override
  String get searchHint => 'Search apps';

  @override
  String get clearSearch => 'Clear search';

  @override
  String get scopeUser => 'Installed';

  @override
  String get scopeSystem => 'System';

  @override
  String get scopeAll => 'All';

  @override
  String get sortLabel => 'Sort';

  @override
  String get sortName => 'Name';

  @override
  String get sortTotalSize => 'Largest first';

  @override
  String get sortCacheSize => 'Most cache first';

  @override
  String get sortRecentlyUpdated => 'Recently updated';

  @override
  String get sortNeedsAccess => 'Sizes need usage access';

  @override
  String totalsLine(int count, String total, String cache) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count apps',
      one: '1 app',
    );
    return '$_temp0 · $total · cache $cache';
  }

  @override
  String totalsCountOnly(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count apps',
      one: '1 app',
    );
    return '$_temp0';
  }

  @override
  String get noApps => 'No apps match.';

  @override
  String get usageAccessTitle => 'See how much space each app uses';

  @override
  String get usageAccessBody =>
      'Android shows app sizes only after you allow Usage access for App Manager. App Manager reads sizes only; nothing leaves your phone.';

  @override
  String get usageAccessButton => 'Allow usage access';

  @override
  String get usageAccessSteps => 'Find App Manager in the list and switch it on, then come back.';

  @override
  String get settingsUnavailable => 'This phone did not open the settings screen.';

  @override
  String get badgeSystem => 'System';

  @override
  String get badgeDisabled => 'Disabled';

  @override
  String versionLine(String version) {
    return 'Version $version';
  }

  @override
  String selectedCount(int count) {
    return '$count selected';
  }

  @override
  String get selectAll => 'Select all shown';

  @override
  String get cancelSelection => 'Cancel selection';

  @override
  String get uninstallSelected => 'Uninstall selected';

  @override
  String batchConfirmTitle(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count apps',
      one: '1 app',
    );
    return 'Uninstall $_temp0?';
  }

  @override
  String get batchConfirmBody =>
      'Android asks you to confirm each app. System apps in the selection are skipped.';

  @override
  String get batchConfirmGo => 'Start';

  @override
  String get cancel => 'Cancel';

  @override
  String batchReport(int removed, int requested) {
    return 'Uninstalled $removed of $requested.';
  }

  @override
  String get openApp => 'Open';

  @override
  String get uninstall => 'Uninstall';

  @override
  String get uninstallUpdates => 'Remove updates';

  @override
  String get appInfo => 'App info';

  @override
  String uninstalled(String label) {
    return '$label was uninstalled.';
  }

  @override
  String get uninstallFailed => 'Android could not start the uninstall.';

  @override
  String get appGone => 'This app is no longer installed.';

  @override
  String get systemAppNote =>
      'Built into the phone. It cannot be uninstalled, but you can disable it in App info.';

  @override
  String get storageTitle => 'Storage';

  @override
  String get storageApp => 'App';

  @override
  String get storageData => 'User data';

  @override
  String get storageCache => 'Cache';

  @override
  String get storageTotal => 'Total';

  @override
  String get storageNoAccess => 'Allow usage access to see this app\'s size.';

  @override
  String get clearCache => 'Clear cache';

  @override
  String get clearCacheSheetTitle => 'Clear the cache in Android\'s settings';

  @override
  String get clearCacheSheetBody =>
      'Android lets only its own settings clear another app\'s cache. App Manager opens the right page for you.';

  @override
  String get clearCacheStep1 => 'Tap Storage & cache (or Storage).';

  @override
  String get clearCacheStep2 => 'Tap Clear cache.';

  @override
  String get clearCacheStep3 => 'Come back here: the new size shows up.';

  @override
  String get permissionsTitle => 'Permissions';

  @override
  String get permissionsAllowed => 'Allowed';

  @override
  String get permissionsDenied => 'Not allowed';

  @override
  String get permissionsSpecial => 'Special access';

  @override
  String permissionsFixed(int count) {
    return 'Granted at install ($count)';
  }

  @override
  String get permissionsNone => 'This app asks for no permissions.';

  @override
  String get permissionsFixedNote =>
      'Android grants these when the app is installed. They cannot be switched off.';

  @override
  String get permissionsError => 'Could not read this app\'s permissions.';

  @override
  String get changePermissions => 'Change permissions';

  @override
  String get permissionsSheetTitle => 'Change permissions in Android\'s settings';

  @override
  String get permissionsSheetBody =>
      'Only Android\'s settings can allow or deny another app\'s permissions. App Manager opens the right page for you.';

  @override
  String get permissionsStep1 => 'Tap Permissions.';

  @override
  String get permissionsStep2 => 'Pick a permission and choose Allow or Don\'t allow.';

  @override
  String get permissionsStep3 => 'Come back here: the list updates.';

  @override
  String get openSettings => 'Open settings';

  @override
  String get detailsTitle => 'Details';

  @override
  String get detailPackage => 'Package';

  @override
  String get detailInstalled => 'Installed';

  @override
  String get detailUpdated => 'Updated';

  @override
  String get detailTargetSdk => 'Target Android API';

  @override
  String get detailMinSdk => 'Minimum Android API';

  @override
  String get detailInstaller => 'Installed from';

  @override
  String get detailInstallerUnknown => 'Unknown (sideloaded or preinstalled)';

  @override
  String get detailStatus => 'Status';

  @override
  String get statusEnabled => 'Enabled';

  @override
  String get statusDisabled => 'Disabled';

  @override
  String get privacyChoices => 'Privacy choices';

  @override
  String get about => 'About';

  @override
  String get aboutBody =>
      'App Manager by HomiLabs lists the apps on your phone with their size and permissions, and takes you straight to uninstalling them, clearing their cache or changing their permissions. Everything stays on your phone.';
}
