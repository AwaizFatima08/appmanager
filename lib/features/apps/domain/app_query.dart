import 'package:appmanager/features/apps/domain/installed_app.dart';
import 'package:flutter/foundation.dart';

/// Which apps the list shows.
enum AppScope { user, system, all }

/// How the list is ordered.
enum AppSort {
  name,
  totalSize,
  cacheSize,
  recentlyUpdated
  ;

  /// Size orders need usage access; without it they fall back to [name].
  bool get needsSizes => this == totalSize || this == cacheSize;
}

/// What the user typed and picked above the list.
@immutable
final class AppQuery {
  const AppQuery({this.search = '', this.scope = AppScope.user, this.sort = AppSort.name});

  final String search;
  final AppScope scope;
  final AppSort sort;

  AppQuery copyWith({String? search, AppScope? scope, AppSort? sort}) => AppQuery(
    search: search ?? this.search,
    scope: scope ?? this.scope,
    sort: sort ?? this.sort,
  );

  @override
  bool operator ==(Object other) =>
      other is AppQuery && other.search == search && other.scope == scope && other.sort == sort;

  @override
  int get hashCode => Object.hash(search, scope, sort);
}

/// An app with its size (null until sizes are known or without usage access).
@immutable
final class AppEntry {
  const AppEntry(this.app, this.size);

  final InstalledApp app;
  final AppStorageSize? size;

  @override
  bool operator ==(Object other) => other is AppEntry && other.app == app && other.size == size;

  @override
  int get hashCode => Object.hash(app, size);
}

/// Totals for the apps currently shown.
typedef AppTotals = ({int count, int totalBytes, int cacheBytes});

/// Filters, searches and sorts [apps] for [query]. Pure and total.
List<AppEntry> selectApps(
  List<InstalledApp> apps,
  Map<String, AppStorageSize> sizes,
  AppQuery query,
) {
  final needle = query.search.trim().toLowerCase();
  final entries = [
    for (final app in apps)
      if (_inScope(app, query.scope) && _matches(app, needle))
        AppEntry(app, sizes[app.packageName]),
  ]..sort(_comparator(query.sort));
  return List.unmodifiable(entries);
}

/// Sums the sizes of [entries]; apps without a size count as zero.
AppTotals totalsOf(List<AppEntry> entries) {
  var total = 0;
  var cache = 0;
  for (final e in entries) {
    total += e.size?.totalBytes ?? 0;
    cache += e.size?.cacheBytes ?? 0;
  }
  return (count: entries.length, totalBytes: total, cacheBytes: cache);
}

bool _inScope(InstalledApp app, AppScope scope) => switch (scope) {
  AppScope.user => !app.isSystem,
  AppScope.system => app.isSystem,
  AppScope.all => true,
};

bool _matches(InstalledApp app, String needle) =>
    needle.isEmpty ||
    app.label.toLowerCase().contains(needle) ||
    app.packageName.toLowerCase().contains(needle);

int Function(AppEntry, AppEntry) _comparator(AppSort sort) {
  int byName(AppEntry a, AppEntry b) {
    final c = a.app.label.toLowerCase().compareTo(b.app.label.toLowerCase());
    return c != 0 ? c : a.app.packageName.compareTo(b.app.packageName);
  }

  return switch (sort) {
    AppSort.name => byName,
    AppSort.totalSize => (a, b) => _desc(
      a.size?.totalBytes,
      b.size?.totalBytes,
      () => byName(a, b),
    ),
    AppSort.cacheSize => (a, b) => _desc(
      a.size?.cacheBytes,
      b.size?.cacheBytes,
      () => byName(a, b),
    ),
    AppSort.recentlyUpdated => (a, b) {
      final c = b.app.lastUpdate.compareTo(a.app.lastUpdate);
      return c != 0 ? c : byName(a, b);
    },
  };
}

/// Larger first; unknown sizes go last; ties broken by [tie].
int _desc(int? a, int? b, int Function() tie) {
  final c = (b ?? -1).compareTo(a ?? -1);
  return c != 0 ? c : tie();
}
