import 'package:appmanager/features/apps/domain/app_permission.dart';
import 'package:appmanager/features/apps/domain/installed_app.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Everything the app asks of Android. Throws [PlatformException] on a native error;
/// the repository turns that into a typed failure.
abstract interface class AppPlatformService {
  Future<List<InstalledApp>> listApps();

  /// Sizes by package name, or null when usage access is not granted.
  Future<Map<String, AppStorageSize>?> sizes();

  Future<List<AppPermission>> permissions(String packageName);

  /// The launcher icon as PNG bytes, or null when the app has gone.
  Future<Uint8List?> icon(String packageName, {required int sizePx});

  Future<bool> hasUsageAccess();

  /// Each `open…` returns false when Android had no screen to show.
  Future<bool> openUsageAccessSettings();

  Future<bool> openAppSettings(String packageName);

  Future<bool> launchApp(String packageName);

  /// Shows Android's uninstall dialog. True when the app is gone afterwards.
  Future<bool> uninstall(String packageName);
}

/// [AppPlatformService] over the `com.homilabs.appmanager/apps` channel (see AppManagerChannel.kt).
class MethodChannelAppPlatformService implements AppPlatformService {
  const MethodChannelAppPlatformService();

  static const _channel = MethodChannel('com.homilabs.appmanager/apps');

  @override
  Future<List<InstalledApp>> listApps() async {
    final raw = await _channel.invokeListMethod<Map<Object?, Object?>>('listApps') ?? const [];
    return [for (final m in raw) _app(m)];
  }

  @override
  Future<Map<String, AppStorageSize>?> sizes() async {
    final raw = await _channel.invokeMapMethod<String, Map<Object?, Object?>>('getSizes');
    if (raw == null) return null;
    return {
      for (final MapEntry(:key, :value) in raw.entries)
        key: AppStorageSize(
          appBytes: _int(value['app']),
          dataBytes: _int(value['data']),
          cacheBytes: _int(value['cache']),
        ),
    };
  }

  @override
  Future<List<AppPermission>> permissions(String packageName) async {
    final raw =
        await _channel.invokeListMethod<Map<Object?, Object?>>(
          'getPermissions',
          _args(packageName),
        ) ??
        const [];
    return [
      for (final m in raw)
        AppPermission(
          name: m['name']! as String,
          kind: PermissionKind.parse(m['protection'] as String?),
          isGranted: m['granted'] == true,
          label: m['label'] as String?,
          description: m['description'] as String?,
        ),
    ];
  }

  @override
  Future<Uint8List?> icon(String packageName, {required int sizePx}) =>
      _channel.invokeMethod<Uint8List>('getIcon', {'packageName': packageName, 'sizePx': sizePx});

  @override
  Future<bool> hasUsageAccess() async =>
      await _channel.invokeMethod<bool>('hasUsageAccess') ?? false;

  @override
  Future<bool> openUsageAccessSettings() async =>
      await _channel.invokeMethod<bool>('openUsageAccessSettings') ?? false;

  @override
  Future<bool> openAppSettings(String packageName) async =>
      await _channel.invokeMethod<bool>('openAppSettings', _args(packageName)) ?? false;

  @override
  Future<bool> launchApp(String packageName) async =>
      await _channel.invokeMethod<bool>('launchApp', _args(packageName)) ?? false;

  @override
  Future<bool> uninstall(String packageName) async =>
      await _channel.invokeMethod<bool>('uninstall', _args(packageName)) ?? false;

  static Map<String, Object?> _args(String packageName) => {'packageName': packageName};

  static int _int(Object? v) => (v as num?)?.toInt() ?? 0;

  static DateTime _time(Object? v) => DateTime.fromMillisecondsSinceEpoch(_int(v));

  static InstalledApp _app(Map<Object?, Object?> m) => InstalledApp(
    packageName: m['packageName']! as String,
    label: m['label'] as String? ?? m['packageName']! as String,
    versionName: m['versionName'] as String? ?? '',
    versionCode: _int(m['versionCode']),
    isSystem: m['isSystem'] == true,
    isUpdatedSystem: m['isUpdatedSystem'] == true,
    isEnabled: m['isEnabled'] != false,
    hasLauncher: m['hasLauncher'] == true,
    firstInstall: _time(m['firstInstallMillis']),
    lastUpdate: _time(m['lastUpdateMillis']),
    targetSdk: _int(m['targetSdk']),
    minSdk: _int(m['minSdk']),
    installer: m['installer'] as String?,
  );
}

final Provider<AppPlatformService> appPlatformServiceProvider = Provider<AppPlatformService>(
  (ref) => const MethodChannelAppPlatformService(),
);
