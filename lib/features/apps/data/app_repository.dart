import 'package:appmanager/core/result.dart';
import 'package:appmanager/features/apps/data/app_platform_service.dart';
import 'package:appmanager/features/apps/domain/app_permission.dart';
import 'package:appmanager/features/apps/domain/installed_app.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What happened after Android's uninstall dialog.
enum UninstallOutcome { removed, keptByUser, failed }

/// The single route to the phone's apps. Every call returns a value or a typed failure.
class AppRepository {
  const AppRepository(this._platform);

  final AppPlatformService _platform;

  Future<Result<List<InstalledApp>, PlatformFailure>> installedApps() =>
      _guard('list_apps', _platform.listApps);

  /// Sizes when usage access is granted; [SizeReport.noAccess] otherwise.
  Future<Result<SizeReport, PlatformFailure>> sizeReport() => _guard('sizes', () async {
    final sizes = await _platform.sizes();
    return sizes == null
        ? const SizeReport.noAccess()
        : SizeReport(hasUsageAccess: true, sizes: Map.unmodifiable(sizes));
  });

  Future<Result<List<AppPermission>, PlatformFailure>> permissions(String packageName) =>
      _guard('permissions', () => _platform.permissions(packageName));

  /// Null when the icon cannot be read; a list row then shows a placeholder.
  Future<Uint8List?> icon(String packageName, {required int sizePx}) async {
    final result = await _guard('icon', () => _platform.icon(packageName, sizePx: sizePx));
    return switch (result) {
      Ok(:final value) => value,
      Err() => null,
    };
  }

  Future<UninstallOutcome> uninstall(String packageName) async {
    final result = await _guard('uninstall', () => _platform.uninstall(packageName));
    return switch (result) {
      Ok(value: true) => UninstallOutcome.removed,
      Ok() => UninstallOutcome.keptByUser,
      Err() => UninstallOutcome.failed,
    };
  }

  /// The `open…` calls return false when Android could not show the screen.
  Future<bool> openAppSettings(String packageName) =>
      _opened('open_settings', () => _platform.openAppSettings(packageName));

  Future<bool> openUsageAccessSettings() =>
      _opened('open_usage_access', _platform.openUsageAccessSettings);

  Future<bool> launchApp(String packageName) =>
      _opened('launch', () => _platform.launchApp(packageName));

  Future<bool> _opened(String code, Future<bool> Function() call) async =>
      switch (await _guard(code, call)) {
        Ok(:final value) => value,
        Err() => false,
      };

  static Future<Result<T, PlatformFailure>> _guard<T>(
    String code,
    Future<T> Function() call,
  ) async {
    try {
      return Ok(await call());
    } on PlatformException catch (e) {
      return Err(PlatformFailure(code, cause: e));
    } on MissingPluginException catch (e) {
      return Err(PlatformFailure(code, cause: e));
    }
  }
}

final Provider<AppRepository> appRepositoryProvider = Provider<AppRepository>(
  (ref) => AppRepository(ref.watch(appPlatformServiceProvider)),
);
