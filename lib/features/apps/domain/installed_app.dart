import 'package:flutter/foundation.dart';

/// One app installed on the phone, as Android's package manager reports it.
@immutable
final class InstalledApp {
  const InstalledApp({
    required this.packageName,
    required this.label,
    required this.versionName,
    required this.versionCode,
    required this.isSystem,
    required this.isUpdatedSystem,
    required this.isEnabled,
    required this.hasLauncher,
    required this.firstInstall,
    required this.lastUpdate,
    required this.targetSdk,
    required this.minSdk,
    this.installer,
  });

  final String packageName;
  final String label;
  final String versionName;
  final int versionCode;

  /// Preinstalled on the system image. Only its updates can be uninstalled.
  final bool isSystem;

  /// A system app that has received an update from a store.
  final bool isUpdatedSystem;
  final bool isEnabled;
  final bool hasLauncher;
  final DateTime firstInstall;
  final DateTime lastUpdate;
  final int targetSdk;
  final int minSdk;

  /// Package name of the store that installed it (e.g. `com.android.vending`), if known.
  final String? installer;

  /// A plain user app can be removed; a system app only when it has updates to remove.
  bool get canUninstall => !isSystem || isUpdatedSystem;

  @override
  bool operator ==(Object other) =>
      other is InstalledApp &&
      other.packageName == packageName &&
      other.label == label &&
      other.versionName == versionName &&
      other.versionCode == versionCode &&
      other.isSystem == isSystem &&
      other.isUpdatedSystem == isUpdatedSystem &&
      other.isEnabled == isEnabled &&
      other.hasLauncher == hasLauncher &&
      other.firstInstall == firstInstall &&
      other.lastUpdate == lastUpdate &&
      other.targetSdk == targetSdk &&
      other.minSdk == minSdk &&
      other.installer == installer;

  @override
  int get hashCode => Object.hash(
    packageName,
    label,
    versionName,
    versionCode,
    isSystem,
    isUpdatedSystem,
    isEnabled,
    hasLauncher,
    firstInstall,
    lastUpdate,
    targetSdk,
    minSdk,
    installer,
  );
}

/// Storage used by one app, in bytes.
@immutable
final class AppStorageSize {
  const AppStorageSize({
    required this.appBytes,
    required this.dataBytes,
    required this.cacheBytes,
  });

  /// The APK and its code.
  final int appBytes;

  /// User data, which Android counts including the cache.
  final int dataBytes;
  final int cacheBytes;

  int get totalBytes => appBytes + dataBytes;

  @override
  bool operator ==(Object other) =>
      other is AppStorageSize &&
      other.appBytes == appBytes &&
      other.dataBytes == dataBytes &&
      other.cacheBytes == cacheBytes;

  @override
  int get hashCode => Object.hash(appBytes, dataBytes, cacheBytes);
}

/// Sizes for every app, or none when the user has not granted usage access.
@immutable
final class SizeReport {
  const SizeReport({required this.hasUsageAccess, required this.sizes});

  const SizeReport.noAccess() : hasUsageAccess = false, sizes = const {};

  final bool hasUsageAccess;
  final Map<String, AppStorageSize> sizes;

  @override
  bool operator ==(Object other) =>
      other is SizeReport &&
      other.hasUsageAccess == hasUsageAccess &&
      mapEquals(other.sizes, sizes);

  @override
  int get hashCode => Object.hash(hasUsageAccess, Object.hashAllUnordered(sizes.entries));
}
