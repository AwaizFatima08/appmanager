import 'package:appmanager/app.dart';
import 'package:appmanager/features/apps/data/app_platform_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'support/fake_platform.dart';

void main() {
  Future<FakePlatform> pump(WidgetTester tester, {bool access = true}) async {
    final platform = FakePlatform(
      apps: [
        fakeApp('com.a.alpha', label: 'Alpha'),
        fakeApp('com.b.beta', label: 'Beta'),
        fakeApp('android.sys', label: 'System UI', isSystem: true),
      ],
      sizeMap: access ? {'com.a.alpha': fakeSize(2000000), 'com.b.beta': fakeSize(5000)} : null,
    );
    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [appPlatformServiceProvider.overrideWithValue(platform)],
        child: const AppManagerApp(),
      ),
    );
    await tester.pumpAndSettle();
    return platform;
  }

  testWidgets('lists user apps with sizes and totals', (tester) async {
    await pump(tester);
    expect(find.text('Alpha'), findsOneWidget);
    expect(find.text('Beta'), findsOneWidget);
    expect(find.text('System UI'), findsNothing);
    expect(find.text('2 MB'), findsOneWidget);
    expect(find.textContaining('2 apps'), findsOneWidget);
  });

  testWidgets('search narrows the list', (tester) async {
    await pump(tester);
    await tester.enterText(find.byType(TextField), 'bet');
    await tester.pumpAndSettle();
    expect(find.text('Alpha'), findsNothing);
    expect(find.text('Beta'), findsOneWidget);
  });

  testWidgets('asks for usage access when sizes are missing', (tester) async {
    final platform = await pump(tester, access: false);
    await tester.tap(find.text('Allow usage access'));
    await tester.pumpAndSettle();
    expect(platform.opened, ['usage']);
  });

  testWidgets('detail screen guides cache clearing into App info', (tester) async {
    final platform = await pump(tester);
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Clear cache'));
    await tester.tap(find.text('Clear cache'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Open settings'));
    await tester.pumpAndSettle();
    expect(platform.opened, ['settings:com.a.alpha']);
  });

  testWidgets('uninstall from detail returns to the list without the app', (tester) async {
    await pump(tester);
    await tester.tap(find.text('Alpha'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Uninstall'));
    await tester.pumpAndSettle();
    expect(find.text('Alpha was uninstalled.'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'Alpha'), findsNothing);
    expect(find.text('Beta'), findsOneWidget);
  });
}
