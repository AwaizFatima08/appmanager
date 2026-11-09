import 'dart:async';

import 'package:appmanager/ads/ad_service.dart';
import 'package:appmanager/app.dart';
import 'package:appmanager/features/apps/application/app_providers.dart';
import 'package:appmanager/features/apps/domain/app_query.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Normal title bar, or the selection bar (count, select all, uninstall) while picking apps.
class ListAppBar extends ConsumerWidget implements PreferredSizeWidget {
  const ListAppBar({required this.visible, super.key});

  /// The rows currently shown, for "Select all shown".
  final List<AppEntry> visible;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final selection = ref.watch(selectionProvider);
    final notifier = ref.read(selectionProvider.notifier);
    if (selection.isEmpty) {
      return AppBar(title: Text(l10n.appTitle), actions: const [_OverflowMenu()]);
    }
    return AppBar(
      leading: IconButton(
        tooltip: l10n.cancelSelection,
        icon: const Icon(Icons.close),
        onPressed: notifier.clear,
      ),
      title: Text(l10n.selectedCount(selection.length)),
      actions: [
        IconButton(
          tooltip: l10n.selectAll,
          icon: const Icon(Icons.select_all),
          onPressed: () => notifier.selectAll(
            visible.where((e) => e.app.canUninstall).map((e) => e.app.packageName),
          ),
        ),
        IconButton(
          tooltip: l10n.uninstallSelected,
          icon: const Icon(Icons.delete_outline),
          onPressed: () => unawaited(_uninstallSelected(context, ref, selection)),
        ),
      ],
    );
  }

  Future<void> _uninstallSelected(
    BuildContext context,
    WidgetRef ref,
    Set<String> selection,
  ) async {
    final apps = ref.read(installedAppsProvider).value ?? const [];
    final names = [
      for (final a in apps)
        if (selection.contains(a.packageName) && a.canUninstall) a.packageName,
    ];
    final go = await showDialog<bool>(
      context: context,
      builder: (context) => _BatchConfirmDialog(count: names.length),
    );
    if (go != true || !context.mounted) return;
    final report = await ref.read(installedAppsProvider.notifier).uninstallAll(names);
    ref.read(selectionProvider.notifier).clear();
    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    await messenger
        .showSnackBar(
          SnackBar(content: Text(context.l10n.batchReport(report.removed, report.requested))),
        )
        .closed;
    await ref.read(adServiceProvider).showBreakInterstitial();
  }
}

class _BatchConfirmDialog extends StatelessWidget {
  const _BatchConfirmDialog({required this.count});

  final int count;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return AlertDialog(
      title: Text(l10n.batchConfirmTitle(count)),
      content: Text(l10n.batchConfirmBody),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, false), child: Text(l10n.cancel)),
        FilledButton(
          onPressed: count == 0 ? null : () => Navigator.pop(context, true),
          child: Text(l10n.batchConfirmGo),
        ),
      ],
    );
  }
}

enum _MenuItem { privacy, about }

class _OverflowMenu extends ConsumerWidget {
  const _OverflowMenu();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final showPrivacy = ref.watch(privacyChoicesRequiredProvider).value ?? false;
    return PopupMenuButton<_MenuItem>(
      onSelected: (item) => unawaited(_select(context, ref, item)),
      itemBuilder: (context) => [
        if (showPrivacy) PopupMenuItem(value: _MenuItem.privacy, child: Text(l10n.privacyChoices)),
        PopupMenuItem(value: _MenuItem.about, child: Text(l10n.about)),
      ],
    );
  }

  Future<void> _select(BuildContext context, WidgetRef ref, _MenuItem item) async {
    switch (item) {
      case _MenuItem.privacy:
        await ref.read(adServiceProvider).showPrivacyChoices();
      case _MenuItem.about:
        showAboutDialog(
          context: context,
          applicationName: context.l10n.appTitle,
          applicationLegalese: '© HomiLabs',
          children: [Text(context.l10n.aboutBody)],
        );
    }
  }
}
