import 'dart:async';

import 'package:appmanager/features/apps/application/app_providers.dart';
import 'package:appmanager/features/apps/view/app_list_screen.dart';
import 'package:appmanager/l10n/gen/app_localizations.dart';
import 'package:appmanager/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

extension L10nX on BuildContext {
  AppLocalizations get l10n => AppLocalizations.of(this);
}

class AppManagerApp extends StatelessWidget {
  const AppManagerApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    onGenerateTitle: (context) => context.l10n.appTitle,
    theme: AppTheme.light(),
    darkTheme: AppTheme.dark(),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: const _RefreshOnResume(child: AppListScreen()),
  );
}

/// Re-reads apps, sizes and permissions whenever the user comes back from Android's
/// Settings or uninstall dialog, where any of them may have changed.
class _RefreshOnResume extends ConsumerStatefulWidget {
  const _RefreshOnResume({required this.child});

  final Widget child;

  @override
  ConsumerState<_RefreshOnResume> createState() => _RefreshOnResumeState();
}

class _RefreshOnResumeState extends ConsumerState<_RefreshOnResume> {
  late final AppLifecycleListener _listener;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(onResume: () => unawaited(_refresh()));
  }

  Future<void> _refresh() async {
    await Future.wait([
      ref.read(installedAppsProvider.notifier).refresh(),
      ref.read(sizeReportProvider.notifier).refresh(),
    ]);
    if (mounted) ref.invalidate(appPermissionsProvider);
  }

  @override
  void dispose() {
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
