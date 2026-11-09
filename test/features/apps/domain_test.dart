import 'package:appmanager/features/apps/domain/app_permission.dart';
import 'package:appmanager/features/apps/domain/app_query.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_platform.dart';

void main() {
  final apps = [
    fakeApp('com.b.notes', label: 'Notes', updatedDay: 3),
    fakeApp('com.a.camera', label: 'camera', updatedDay: 9),
    fakeApp('android.settings', label: 'Settings', isSystem: true),
    fakeApp('com.c.chat', label: 'Chat', updatedDay: 5),
  ];
  final sizes = {
    'com.b.notes': fakeSize(500, cache: 10),
    'com.a.camera': fakeSize(100, cache: 90),
    'android.settings': fakeSize(900),
  };
  List<String> names(AppQuery q) => [for (final e in selectApps(apps, sizes, q)) e.app.label];

  group('selectApps', () {
    test('user scope by name, case-insensitive', () {
      expect(names(const AppQuery()), ['camera', 'Chat', 'Notes']);
    });

    test('system and all scopes', () {
      expect(names(const AppQuery(scope: AppScope.system)), ['Settings']);
      expect(names(const AppQuery(scope: AppScope.all)), hasLength(4));
    });

    test('search matches label or package name', () {
      expect(names(const AppQuery(search: ' NOT ')), ['Notes']);
      expect(names(const AppQuery(search: 'com.c')), ['Chat']);
    });

    test('size sorts put unknown sizes last', () {
      expect(names(const AppQuery(sort: AppSort.totalSize)), ['Notes', 'camera', 'Chat']);
      expect(names(const AppQuery(sort: AppSort.cacheSize)), ['camera', 'Notes', 'Chat']);
    });

    test('recently updated first', () {
      expect(names(const AppQuery(sort: AppSort.recentlyUpdated)), ['camera', 'Chat', 'Notes']);
    });

    test('totals ignore apps without a size', () {
      final t = totalsOf(selectApps(apps, sizes, const AppQuery()));
      expect(t, (count: 3, totalBytes: 600, cacheBytes: 100));
    });
  });

  test('a system app can be uninstalled only when it has updates', () {
    expect(fakeApp('x').canUninstall, isTrue);
    expect(fakeApp('x', isSystem: true).canUninstall, isFalse);
    expect(fakeApp('x', isSystem: true, isUpdatedSystem: true).canUninstall, isTrue);
  });

  group('permissions', () {
    const camera = AppPermission(
      name: 'android.permission.CAMERA',
      kind: PermissionKind.dangerous,
      isGranted: true,
      label: 'take pictures and videos',
    );
    const location = AppPermission(
      name: 'android.permission.ACCESS_FINE_LOCATION',
      kind: PermissionKind.dangerous,
      isGranted: false,
    );
    const overlay = AppPermission(
      name: 'android.permission.SYSTEM_ALERT_WINDOW',
      kind: PermissionKind.special,
      isGranted: false,
    );
    const internet = AppPermission(
      name: 'android.permission.INTERNET',
      kind: PermissionKind.normal,
      isGranted: true,
    );

    test('display name uses the system label, else the name in words', () {
      expect(camera.displayName, 'Take pictures and videos');
      expect(location.displayName, 'Access fine location');
    });

    test('groups split by what the user can change', () {
      final g = PermissionGroups.of(const [internet, overlay, location, camera]);
      expect(g.allowed, [camera]);
      expect(g.denied, [location]);
      expect(g.special, [overlay]);
      expect(g.fixed, [internet]);
      expect(PermissionGroups.of(const []).isEmpty, isTrue);
    });

    test('unknown protection strings parse to unknown', () {
      expect(PermissionKind.parse('dangerous'), PermissionKind.dangerous);
      expect(PermissionKind.parse('weird'), PermissionKind.unknown);
      expect(PermissionKind.parse(null), PermissionKind.unknown);
    });
  });
}
