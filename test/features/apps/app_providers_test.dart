import 'package:appmanager/features/apps/application/app_providers.dart';
import 'package:appmanager/features/apps/data/app_platform_service.dart';
import 'package:appmanager/features/apps/data/app_repository.dart';
import 'package:appmanager/features/apps/domain/app_query.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../support/fake_platform.dart';

void main() {
  late FakePlatform platform;
  late ProviderContainer container;

  setUp(() {
    platform = FakePlatform(
      apps: [
        fakeApp('com.a', label: 'Alpha'),
        fakeApp('com.b', label: 'Beta'),
      ],
      sizeMap: {'com.a': fakeSize(10), 'com.b': fakeSize(20)},
    );
    container = ProviderContainer.test(
      retry: (_, _) => null,
      overrides: [appPlatformServiceProvider.overrideWithValue(platform)],
    );
  });

  Future<List<String>> visible() async {
    await container.read(installedAppsProvider.future);
    await container.read(sizeReportProvider.future);
    return [for (final e in container.read(visibleAppsProvider).requireValue) e.app.packageName];
  }

  test('visible apps follow the query', () async {
    expect(await visible(), ['com.a', 'com.b']);
    container.read(appQueryProvider.notifier).sort(AppSort.totalSize);
    expect(await visible(), ['com.b', 'com.a']);
  });

  test('a confirmed uninstall drops the app from the list', () async {
    await visible();
    final outcome = await container.read(installedAppsProvider.notifier).uninstall('com.a');
    expect(outcome, UninstallOutcome.removed);
    expect(await visible(), ['com.b']);
  });

  test('a cancelled uninstall keeps the app', () async {
    platform.uninstallAccepted = false;
    await visible();
    final outcome = await container.read(installedAppsProvider.notifier).uninstall('com.a');
    expect(outcome, UninstallOutcome.keptByUser);
    expect(await visible(), ['com.a', 'com.b']);
  });

  test('batch uninstall reports how many went', () async {
    await visible();
    final report = await container.read(installedAppsProvider.notifier).uninstallAll([
      'com.a',
      'com.b',
    ]);
    expect(report, (removed: 2, requested: 2));
    expect(await visible(), isEmpty);
  });

  test('without usage access the report says so and sizes are empty', () async {
    platform.sizeMap = null;
    final report = await container.read(sizeReportProvider.future);
    expect(report.hasUsageAccess, isFalse);
    expect(report.sizes, isEmpty);
  });

  test('selection toggles and clears', () {
    final notifier = container.read(selectionProvider.notifier)..toggle('com.a');
    expect(container.read(selectionProvider), {'com.a'});
    notifier.toggle('com.a');
    expect(container.read(selectionProvider), isEmpty);
    notifier.selectAll(['com.a', 'com.b']);
    expect(container.read(selectionProvider), hasLength(2));
    notifier.clear();
    expect(container.read(selectionProvider), isEmpty);
  });
}
