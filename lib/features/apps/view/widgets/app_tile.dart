import 'package:appmanager/app.dart';
import 'package:appmanager/core/byte_size.dart';
import 'package:appmanager/features/apps/domain/app_query.dart';
import 'package:appmanager/features/apps/view/widgets/app_icon.dart';
import 'package:flutter/material.dart';

/// One row of the app list: icon, name, version and size.
class AppTile extends StatelessWidget {
  const AppTile({
    required this.entry,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
    super.key,
  });

  final AppEntry entry;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  @override
  Widget build(BuildContext context) {
    final app = entry.app;
    final size = entry.size;
    final locale = Localizations.localeOf(context).toString();
    return ListTile(
      selected: isSelected,
      onTap: onTap,
      onLongPress: onLongPress,
      leading: isSelected
          ? const SizedBox.square(dimension: 40, child: Icon(Icons.check_circle))
          : AppIcon(packageName: app.packageName),
      title: Text(app.label, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: _Subtitle(
        version: app.versionName,
        isSystem: app.isSystem,
        isDisabled: !app.isEnabled,
      ),
      trailing: size == null
          ? null
          : Text(
              formatBytes(size.totalBytes, locale: locale),
              style: Theme.of(context).textTheme.labelLarge,
            ),
    );
  }
}

class _Subtitle extends StatelessWidget {
  const _Subtitle({required this.version, required this.isSystem, required this.isDisabled});

  final String version;
  final bool isSystem;
  final bool isDisabled;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final parts = [
      if (version.isNotEmpty) l10n.versionLine(version),
      if (isSystem) l10n.badgeSystem,
      if (isDisabled) l10n.badgeDisabled,
    ];
    return Text(parts.join(' · '), maxLines: 1, overflow: TextOverflow.ellipsis);
  }
}
