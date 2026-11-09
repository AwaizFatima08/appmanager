import 'dart:typed_data';

import 'package:appmanager/core/result.dart';
import 'package:appmanager/features/apps/data/app_repository.dart';
import 'package:appmanager/features/apps/domain/app_permission.dart';
import 'package:appmanager/features/apps/domain/app_query.dart';
import 'package:appmanager/features/apps/domain/installed_app.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The installed apps. Owns removal, so the list updates the moment an uninstall succeeds.
class InstalledAppsNotifier extends AsyncNotifier<List<InstalledApp>> {
  @override
  Future<List<InstalledApp>> build() => _load();

  /// Re-reads the list without showing a spinner (pull to refresh, back from Settings).
  Future<void> refresh() async {
    final next = await AsyncValue.guard(_load);
    if (ref.mounted) state = next;
  }

  /// Shows Android's uninstall dialog for [packageName].
  Future<UninstallOutcome> uninstall(String packageName) async {
    final outcome = await ref.read(appRepositoryProvider).uninstall(packageName);
    if (outcome == UninstallOutcome.removed && ref.mounted) _drop({packageName});
    return outcome;
  }

  /// Uninstalls [packageNames] one dialog at a time.
  Future<BatchUninstallReport> uninstallAll(List<String> packageNames) async {
    final repository = ref.read(appRepositoryProvider);
    final removed = <String>{};
    for (final name in packageNames) {
      if (!ref.mounted) break;
      if (await repository.uninstall(name) == UninstallOutcome.removed) removed.add(name);
    }
    if (ref.mounted) _drop(removed);
    return (removed: removed.length, requested: packageNames.length);
  }

  void _drop(Set<String> packageNames) {
    final apps = state.value;
    if (apps == null || packageNames.isEmpty) return;
    state = AsyncData(
      List.unmodifiable(apps.where((a) => !packageNames.contains(a.packageName))),
    );
  }

  Future<List<InstalledApp>> _load() async =>
      switch (await ref.read(appRepositoryProvider).installedApps()) {
        Ok(:final value) => List.unmodifiable(value),
        Err(:final failure) => throw failure,
      };
}

/// How many of a batch uninstall went through.
typedef BatchUninstallReport = ({int removed, int requested});

final installedAppsProvider = AsyncNotifierProvider<InstalledAppsNotifier, List<InstalledApp>>(
  InstalledAppsNotifier.new,
);

/// App sizes. Loaded after the list (it is slower) and re-read on return from Settings.
class SizeReportNotifier extends AsyncNotifier<SizeReport> {
  @override
  Future<SizeReport> build() => _load();

  Future<void> refresh() async {
    final next = await AsyncValue.guard(_load);
    if (ref.mounted) state = next;
  }

  Future<SizeReport> _load() async => switch (await ref.read(appRepositoryProvider).sizeReport()) {
    Ok(:final value) => value,
    Err(:final failure) => throw failure,
  };
}

final sizeReportProvider = AsyncNotifierProvider<SizeReportNotifier, SizeReport>(
  SizeReportNotifier.new,
);

/// Search text, scope and sort chosen above the list.
class AppQueryNotifier extends Notifier<AppQuery> {
  @override
  AppQuery build() => const AppQuery();

  void search(String text) => state = state.copyWith(search: text);

  void scope(AppScope scope) => state = state.copyWith(scope: scope);

  void sort(AppSort sort) => state = state.copyWith(sort: sort);
}

final appQueryProvider = NotifierProvider<AppQueryNotifier, AppQuery>(AppQueryNotifier.new);

/// The rows the list shows: derived from the apps, their sizes and the query.
final visibleAppsProvider = Provider<AsyncValue<List<AppEntry>>>((ref) {
  final apps = ref.watch(installedAppsProvider);
  final sizes = ref.watch(sizeReportProvider).value?.sizes ?? const {};
  final query = ref.watch(appQueryProvider);
  return apps.whenData((list) => selectApps(list, sizes, query));
});

/// Package names picked for a batch uninstall (long-press a row to start).
class SelectionNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() => const {};

  void toggle(String packageName) => state = Set.unmodifiable(
    state.contains(packageName) ? ({...state}..remove(packageName)) : {...state, packageName},
  );

  void selectAll(Iterable<String> packageNames) => state = Set.unmodifiable(packageNames);

  void clear() => state = const {};
}

final selectionProvider = NotifierProvider<SelectionNotifier, Set<String>>(SelectionNotifier.new);

/// Icon PNGs, kept once read so scrolling does not reload them.
final appIconProvider = FutureProvider.family<Uint8List?, String>(
  (ref, packageName) => ref.watch(appRepositoryProvider).icon(packageName, sizePx: 96),
);

/// One app's permissions, re-read every time its screen opens.
final appPermissionsProvider = FutureProvider.autoDispose.family<PermissionGroups, String>((
  ref,
  packageName,
) async {
  final result = await ref.watch(appRepositoryProvider).permissions(packageName);
  return switch (result) {
    Ok(:final value) => PermissionGroups.of(value),
    Err(:final failure) => throw failure,
  };
});

/// One app by package name, null once it has been uninstalled.
final appByPackageProvider = Provider.autoDispose.family<AppEntry?, String>((ref, packageName) {
  final apps = ref.watch(installedAppsProvider).value ?? const [];
  final app = apps.where((a) => a.packageName == packageName).firstOrNull;
  if (app == null) return null;
  return AppEntry(app, ref.watch(sizeReportProvider).value?.sizes[packageName]);
});
