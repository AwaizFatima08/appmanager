import 'dart:typed_data';

import 'package:appmanager/features/apps/data/app_platform_service.dart';
import 'package:appmanager/features/apps/domain/app_permission.dart';
import 'package:appmanager/features/apps/domain/installed_app.dart';

InstalledApp fakeApp(
  String packageName, {
  String? label,
  bool isSystem = false,
  bool isUpdatedSystem = false,
  int updatedDay = 1,
}) => InstalledApp(
  packageName: packageName,
  label: label ?? packageName,
  versionName: '1.0',
  versionCode: 1,
  isSystem: isSystem,
  isUpdatedSystem: isUpdatedSystem,
  isEnabled: true,
  hasLauncher: true,
  firstInstall: DateTime.utc(2026),
  lastUpdate: DateTime.utc(2026, 1, updatedDay),
  targetSdk: 35,
  minSdk: 26,
);

AppStorageSize fakeSize(int total, {int cache = 0}) =>
    AppStorageSize(appBytes: total ~/ 2, dataBytes: total - total ~/ 2, cacheBytes: cache);

/// An in-memory phone. [uninstallAccepted] decides what the "user" taps in the dialog.
class FakePlatform implements AppPlatformService {
  FakePlatform({
    required List<InstalledApp> apps,
    this.sizeMap,
    this.permissionList = const [],
    this.uninstallAccepted = true,
  }) : _apps = [...apps];

  final List<InstalledApp> _apps;
  Map<String, AppStorageSize>? sizeMap;
  List<AppPermission> permissionList;
  bool uninstallAccepted;
  final List<String> opened = [];

  @override
  Future<List<InstalledApp>> listApps() async => List.of(_apps);

  @override
  Future<Map<String, AppStorageSize>?> sizes() async => sizeMap;

  @override
  Future<List<AppPermission>> permissions(String packageName) async => permissionList;

  @override
  Future<Uint8List?> icon(String packageName, {required int sizePx}) async => null;

  @override
  Future<bool> hasUsageAccess() async => sizeMap != null;

  @override
  Future<bool> openUsageAccessSettings() async {
    opened.add('usage');
    return true;
  }

  @override
  Future<bool> openAppSettings(String packageName) async {
    opened.add('settings:$packageName');
    return true;
  }

  @override
  Future<bool> launchApp(String packageName) async => true;

  @override
  Future<bool> uninstall(String packageName) async {
    if (!uninstallAccepted) return false;
    _apps.removeWhere((a) => a.packageName == packageName);
    return true;
  }
}
