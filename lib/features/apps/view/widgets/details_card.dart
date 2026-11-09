import 'package:appmanager/app.dart';
import 'package:appmanager/features/apps/domain/installed_app.dart';
import 'package:appmanager/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// Package name, dates, Android API levels and install source.
class DetailsCard extends StatelessWidget {
  const DetailsCard({required this.app, super.key});

  final InstalledApp app;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final date = DateFormat.yMMMd(Localizations.localeOf(context).toString());
    return Card(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.detailsTitle, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: AppSpacing.sm),
            _Row(label: l10n.detailPackage, value: app.packageName),
            _Row(label: l10n.detailInstalled, value: date.format(app.firstInstall)),
            _Row(label: l10n.detailUpdated, value: date.format(app.lastUpdate)),
            _Row(label: l10n.detailTargetSdk, value: '${app.targetSdk}'),
            _Row(label: l10n.detailMinSdk, value: '${app.minSdk}'),
            _Row(label: l10n.detailInstaller, value: app.installer ?? l10n.detailInstallerUnknown),
            _Row(
              label: l10n.detailStatus,
              value: app.isEnabled ? l10n.statusEnabled : l10n.statusDisabled,
            ),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.symmetric(vertical: AppSpacing.xs),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(flex: 2, child: Text(label, style: Theme.of(context).textTheme.bodySmall)),
        Expanded(flex: 3, child: SelectableText(value)),
      ],
    ),
  );
}
