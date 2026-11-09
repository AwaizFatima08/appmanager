import 'package:appmanager/app.dart';
import 'package:appmanager/features/apps/data/app_repository.dart';
import 'package:appmanager/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Explains the taps to make in Android's App info page, then opens it.
///
/// Used where Android allows only its own settings to act: clearing another app's cache
/// and changing its permissions.
Future<void> showSettingsGuide(
  BuildContext context,
  WidgetRef ref, {
  required String packageName,
  required String title,
  required String body,
  required List<String> steps,
}) async {
  final open = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (context) => _GuideSheet(title: title, body: body, steps: steps),
  );
  if (open != true || !context.mounted) return;
  await openAppSettings(context, ref, packageName);
}

/// Opens App info for [packageName]; tells the user when the phone has no such screen.
Future<void> openAppSettings(BuildContext context, WidgetRef ref, String packageName) async {
  final opened = await ref.read(appRepositoryProvider).openAppSettings(packageName);
  if (!opened && context.mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.settingsUnavailable)),
    );
  }
}

class _GuideSheet extends StatelessWidget {
  const _GuideSheet({required this.title, required this.body, required this.steps});

  final String title;
  final String body;
  final List<String> steps;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsetsDirectional.zero,
        child: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(
            AppSpacing.lg,
            0,
            AppSpacing.lg,
            AppSpacing.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: theme.textTheme.titleLarge),
              const SizedBox(height: AppSpacing.sm),
              Text(body),
              const SizedBox(height: AppSpacing.md),
              for (final (i, step) in steps.indexed) _Step(number: i + 1, text: step),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pop(context, true),
                  icon: const Icon(Icons.open_in_new),
                  label: Text(context.l10n.openSettings),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  const _Step({required this.number, required this.text});

  final int number;
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsetsDirectional.only(bottom: AppSpacing.sm),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(radius: 12, child: Text('$number', style: const TextStyle(fontSize: 12))),
        const SizedBox(width: AppSpacing.sm),
        Expanded(child: Text(text)),
      ],
    ),
  );
}
