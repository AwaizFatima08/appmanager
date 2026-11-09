import 'dart:async';

import 'package:appmanager/app.dart';
import 'package:appmanager/features/apps/application/app_providers.dart';
import 'package:appmanager/features/apps/domain/app_permission.dart';
import 'package:appmanager/features/apps/view/widgets/settings_guide_sheet.dart';
import 'package:appmanager/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// What the app may do, split into allowed / not allowed / special / fixed.
class PermissionsCard extends ConsumerWidget {
  const PermissionsCard({required this.packageName, super.key});

  final String packageName;

  void _change(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    unawaited(
      showSettingsGuide(
        context,
        ref,
        packageName: packageName,
        title: l10n.permissionsSheetTitle,
        body: l10n.permissionsSheetBody,
        steps: [l10n.permissionsStep1, l10n.permissionsStep2, l10n.permissionsStep3],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final groups = ref.watch(appPermissionsProvider(packageName));
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.permissionsTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            switch (groups) {
              AsyncData(:final value) => _Groups(groups: value),
              AsyncError() => Text(l10n.permissionsError),
              _ => const LinearProgressIndicator(),
            },
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => _change(context, ref),
              icon: const Icon(Icons.tune),
              label: Text(l10n.changePermissions),
            ),
          ],
        ),
      ),
    );
  }
}

class _Groups extends StatelessWidget {
  const _Groups({required this.groups});

  final PermissionGroups groups;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (groups.isEmpty) return Text(l10n.permissionsNone);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Group(
          title: l10n.permissionsAllowed,
          items: groups.allowed,
          icon: Icons.check_circle_outline,
        ),
        _Group(title: l10n.permissionsDenied, items: groups.denied, icon: Icons.block),
        _Group(title: l10n.permissionsSpecial, items: groups.special, icon: Icons.star_outline),
        if (groups.fixed.isNotEmpty)
          ExpansionTile(
            tilePadding: EdgeInsetsDirectional.zero,
            title: Text(l10n.permissionsFixed(groups.fixed.length)),
            subtitle: Text(l10n.permissionsFixedNote),
            children: [
              for (final p in groups.fixed) _PermissionRow(permission: p, icon: Icons.lock_outline),
            ],
          ),
      ],
    );
  }
}

class _Group extends StatelessWidget {
  const _Group({required this.title, required this.items, required this.icon});

  final String title;
  final List<AppPermission> items;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.labelLarge),
          for (final p in items) _PermissionRow(permission: p, icon: icon),
        ],
      ),
    );
  }
}

class _PermissionRow extends StatelessWidget {
  const _PermissionRow({required this.permission, required this.icon});

  final AppPermission permission;
  final IconData icon;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    contentPadding: EdgeInsetsDirectional.zero,
    leading: Icon(icon, size: 20),
    title: Text(permission.displayName),
    subtitle: Text(permission.name, maxLines: 1, overflow: TextOverflow.ellipsis),
  );
}
