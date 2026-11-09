import 'dart:async';

import 'package:appmanager/app.dart';
import 'package:appmanager/features/apps/application/app_providers.dart';
import 'package:appmanager/features/apps/data/app_repository.dart';
import 'package:appmanager/features/apps/domain/installed_app.dart';
import 'package:appmanager/features/apps/view/widgets/app_icon.dart';
import 'package:appmanager/features/apps/view/widgets/details_card.dart';
import 'package:appmanager/features/apps/view/widgets/permissions_card.dart';
import 'package:appmanager/features/apps/view/widgets/settings_guide_sheet.dart';
import 'package:appmanager/features/apps/view/widgets/storage_card.dart';
import 'package:appmanager/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// One app: open, uninstall, size and cache, permissions, details.
class AppDetailScreen extends ConsumerWidget {
  const AppDetailScreen({required this.packageName, super.key});

  final String packageName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entry = ref.watch(appByPackageProvider(packageName));
    if (entry == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(context.l10n.appGone)),
      );
    }
    final app = entry.app;
    return Scaffold(
      appBar: AppBar(title: Text(app.label)),
      body: ListView(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        children: [
          _Header(app: app),
          const SizedBox(height: AppSpacing.md),
          _Actions(app: app),
          const SizedBox(height: AppSpacing.md),
          StorageCard(packageName: packageName, size: entry.size),
          PermissionsCard(packageName: packageName),
          DetailsCard(app: app),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.app});

  final InstalledApp app;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      children: [
        AppIcon(packageName: app.packageName, size: 64),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(app.label, style: theme.textTheme.titleLarge),
              if (app.versionName.isNotEmpty) Text(context.l10n.versionLine(app.versionName)),
              if (app.isSystem && !app.canUninstall)
                Padding(
                  padding: const EdgeInsetsDirectional.only(top: AppSpacing.xs),
                  child: Text(context.l10n.systemAppNote, style: theme.textTheme.bodySmall),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Actions extends ConsumerWidget {
  const _Actions({required this.app});

  final InstalledApp app;

  Future<void> _uninstall(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final outcome = await ref.read(installedAppsProvider.notifier).uninstall(app.packageName);
    switch (outcome) {
      case UninstallOutcome.removed:
        messenger.showSnackBar(SnackBar(content: Text(l10n.uninstalled(app.label))));
        navigator.pop();
      case UninstallOutcome.failed:
        messenger.showSnackBar(SnackBar(content: Text(l10n.uninstallFailed)));
      case UninstallOutcome.keptByUser:
        break;
    }
  }

  Future<void> _launch(BuildContext context, WidgetRef ref) async {
    final opened = await ref.read(appRepositoryProvider).launchApp(app.packageName);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.settingsUnavailable)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Wrap(
      spacing: AppSpacing.sm,
      runSpacing: AppSpacing.sm,
      children: [
        if (app.hasLauncher)
          FilledButton.tonalIcon(
            onPressed: () => unawaited(_launch(context, ref)),
            icon: const Icon(Icons.open_in_new),
            label: Text(l10n.openApp),
          ),
        if (app.canUninstall)
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            onPressed: () => unawaited(_uninstall(context, ref)),
            icon: const Icon(Icons.delete_outline),
            label: Text(app.isSystem ? l10n.uninstallUpdates : l10n.uninstall),
          ),
        OutlinedButton.icon(
          onPressed: () => unawaited(openAppSettings(context, ref, app.packageName)),
          icon: const Icon(Icons.settings_outlined),
          label: Text(l10n.appInfo),
        ),
      ],
    );
  }
}
