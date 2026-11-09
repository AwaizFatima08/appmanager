import 'dart:async';

import 'package:appmanager/app.dart';
import 'package:appmanager/core/byte_size.dart';
import 'package:appmanager/features/apps/domain/installed_app.dart';
import 'package:appmanager/features/apps/view/widgets/settings_guide_sheet.dart';
import 'package:appmanager/features/apps/view/widgets/usage_access_banner.dart';
import 'package:appmanager/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// App, data and cache sizes, with the way to clear the cache.
class StorageCard extends ConsumerWidget {
  const StorageCard({required this.packageName, required this.size, super.key});

  final String packageName;

  /// Null without usage access.
  final AppStorageSize? size;

  void _clearCache(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    unawaited(
      showSettingsGuide(
        context,
        ref,
        packageName: packageName,
        title: l10n.clearCacheSheetTitle,
        body: l10n.clearCacheSheetBody,
        steps: [l10n.clearCacheStep1, l10n.clearCacheStep2, l10n.clearCacheStep3],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final s = size;
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.storageTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            if (s == null) ...[
              Text(l10n.storageNoAccess),
              TextButton(
                onPressed: () => unawaited(openUsageAccess(context, ref)),
                child: Text(l10n.usageAccessButton),
              ),
            ] else
              _SizeTable(size: s),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: () => _clearCache(context, ref),
              icon: const Icon(Icons.cleaning_services_outlined),
              label: Text(l10n.clearCache),
            ),
          ],
        ),
      ),
    );
  }
}

class _SizeTable extends StatelessWidget {
  const _SizeTable({required this.size});

  final AppStorageSize size;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    String f(int b) => formatBytes(b, locale: locale);
    final bold = Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold);
    return Column(
      children: [
        _SizeRow(label: l10n.storageApp, value: f(size.appBytes)),
        _SizeRow(label: l10n.storageData, value: f(size.userDataBytes)),
        _SizeRow(label: l10n.storageCache, value: f(size.cacheBytes), color: AppColors.amber),
        const Divider(),
        _SizeRow(label: l10n.storageTotal, value: f(size.totalBytes), style: bold),
      ],
    );
  }
}

class _SizeRow extends StatelessWidget {
  const _SizeRow({required this.label, required this.value, this.color, this.style});

  final String label;
  final String value;
  final Color? color;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.symmetric(vertical: 2),
    child: Row(
      children: [
        Expanded(child: Text(label, style: style)),
        Text(value, style: (style ?? const TextStyle()).copyWith(color: color)),
      ],
    ),
  );
}
