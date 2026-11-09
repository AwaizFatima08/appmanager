import 'dart:async';

import 'package:appmanager/ads/ad_service.dart';
import 'package:appmanager/app.dart';
import 'package:appmanager/core/byte_size.dart';
import 'package:appmanager/core/result.dart';
import 'package:appmanager/features/apps/application/app_providers.dart';
import 'package:appmanager/features/apps/domain/app_query.dart';
import 'package:appmanager/features/apps/view/app_detail_screen.dart';
import 'package:appmanager/features/apps/view/widgets/app_tile.dart';
import 'package:appmanager/features/apps/view/widgets/list_app_bar.dart';
import 'package:appmanager/features/apps/view/widgets/query_bar.dart';
import 'package:appmanager/features/apps/view/widgets/usage_access_banner.dart';
import 'package:appmanager/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Home: every app on the phone, searchable and sortable by size.
class AppListScreen extends ConsumerWidget {
  const AppListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visible = ref.watch(visibleAppsProvider);
    final noAccess = ref.watch(sizeReportProvider).value?.hasUsageAccess == false;
    final selecting = ref.watch(selectionProvider).isNotEmpty;
    return PopScope(
      canPop: !selecting,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) ref.read(selectionProvider.notifier).clear();
      },
      child: Scaffold(
        appBar: ListAppBar(visible: visible.value ?? const []),
        body: Column(
          children: [
            if (noAccess) const UsageAccessBanner(),
            const QueryBar(),
            Expanded(
              child: switch (visible) {
                AsyncData(:final value) => _AppList(entries: value),
                AsyncError(:final error) => _LoadError(error: error),
                _ => const Center(child: CircularProgressIndicator()),
              },
            ),
          ],
        ),
        bottomNavigationBar: selecting
            ? null
            : SafeArea(child: ref.watch(adServiceProvider).banner()),
      ),
    );
  }
}

class _AppList extends ConsumerWidget {
  const _AppList({required this.entries});

  final List<AppEntry> entries;

  Future<void> _refresh(WidgetRef ref) async {
    await Future.wait([
      ref.read(installedAppsProvider.notifier).refresh(),
      ref.read(sizeReportProvider.notifier).refresh(),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selection = ref.watch(selectionProvider);
    final showCache = ref.watch(appQueryProvider.select((q) => q.sort == AppSort.cacheSize));
    return RefreshIndicator(
      onRefresh: () => _refresh(ref),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _TotalsLine(entries: entries)),
          if (entries.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Center(child: Text(context.l10n.noApps)),
            )
          else
            SliverList.builder(
              itemCount: entries.length,
              itemBuilder: (context, i) {
                final entry = entries[i];
                final name = entry.app.packageName;
                void toggle() => ref.read(selectionProvider.notifier).toggle(name);
                return AppTile(
                  key: ValueKey(name),
                  entry: entry,
                  isSelected: selection.contains(name),
                  showCache: showCache,
                  onLongPress: toggle,
                  onTap: selection.isEmpty ? () => unawaited(_openDetail(context, name)) : toggle,
                );
              },
            ),
        ],
      ),
    );
  }

  static Future<void> _openDetail(BuildContext context, String packageName) =>
      Navigator.of(context).push(
        MaterialPageRoute<void>(builder: (_) => AppDetailScreen(packageName: packageName)),
      );
}

class _TotalsLine extends StatelessWidget {
  const _TotalsLine({required this.entries});

  final List<AppEntry> entries;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final totals = totalsOf(entries);
    final hasSizes = entries.any((e) => e.size != null);
    final text = hasSizes
        ? l10n.totalsLine(
            totals.count,
            formatBytes(totals.totalBytes, locale: locale),
            formatBytes(totals.cacheBytes, locale: locale),
          )
        : l10n.totalsCountOnly(totals.count);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md,
        AppSpacing.sm,
        AppSpacing.md,
        AppSpacing.xs,
      ),
      child: Text(text, style: Theme.of(context).textTheme.labelMedium),
    );
  }
}

class _LoadError extends ConsumerWidget {
  const _LoadError({required this.error});

  final Object error;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final code = error is Failure ? (error as Failure).code : '$error';
    return Center(
      child: Padding(
        padding: const EdgeInsetsDirectional.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(l10n.loadError(code), textAlign: TextAlign.center),
            const SizedBox(height: AppSpacing.md),
            FilledButton(
              onPressed: () => ref.invalidate(installedAppsProvider),
              child: Text(l10n.retry),
            ),
          ],
        ),
      ),
    );
  }
}
