import 'package:appmanager/app.dart';
import 'package:appmanager/features/apps/application/app_providers.dart';
import 'package:appmanager/features/apps/domain/app_query.dart';
import 'package:appmanager/l10n/gen/app_localizations.dart';
import 'package:appmanager/ui/theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Search field, Installed/System/All switch and the sort menu.
class QueryBar extends ConsumerStatefulWidget {
  const QueryBar({super.key});

  @override
  ConsumerState<QueryBar> createState() => _QueryBarState();
}

class _QueryBarState extends ConsumerState<QueryBar> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _clear() {
    _search.clear();
    ref.read(appQueryProvider.notifier).search('');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final query = ref.watch(appQueryProvider);
    final notifier = ref.read(appQueryProvider.notifier);
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(AppSpacing.md, AppSpacing.sm, AppSpacing.md, 0),
      child: Column(
        children: [
          TextField(
            controller: _search,
            onChanged: notifier.search,
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: l10n.searchHint,
              prefixIcon: const Icon(Icons.search),
              suffixIcon: query.search.isEmpty
                  ? null
                  : IconButton(
                      tooltip: l10n.clearSearch,
                      icon: const Icon(Icons.close),
                      onPressed: _clear,
                    ),
              border: const OutlineInputBorder(),
              isDense: true,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Row(
            children: [
              Expanded(
                child: _ScopeSwitch(scope: query.scope, onChanged: notifier.scope),
              ),
              const SizedBox(width: AppSpacing.sm),
              _SortMenu(sort: query.sort, onChanged: notifier.sort),
            ],
          ),
        ],
      ),
    );
  }
}

class _ScopeSwitch extends StatelessWidget {
  const _ScopeSwitch({required this.scope, required this.onChanged});

  final AppScope scope;
  final ValueChanged<AppScope> onChanged;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return SegmentedButton<AppScope>(
      showSelectedIcon: false,
      segments: [
        ButtonSegment(value: AppScope.user, label: Text(l10n.scopeUser)),
        ButtonSegment(value: AppScope.system, label: Text(l10n.scopeSystem)),
        ButtonSegment(value: AppScope.all, label: Text(l10n.scopeAll)),
      ],
      selected: {scope},
      onSelectionChanged: (s) => onChanged(s.single),
    );
  }
}

class _SortMenu extends ConsumerWidget {
  const _SortMenu({required this.sort, required this.onChanged});

  final AppSort sort;
  final ValueChanged<AppSort> onChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final hasSizes = ref.watch(sizeReportProvider).value?.hasUsageAccess ?? false;
    return PopupMenuButton<AppSort>(
      tooltip: l10n.sortLabel,
      icon: const Icon(Icons.sort),
      initialValue: sort,
      onSelected: onChanged,
      itemBuilder: (context) => [
        for (final option in AppSort.values)
          CheckedPopupMenuItem(
            value: option,
            checked: option == sort,
            enabled: hasSizes || !option.needsSizes,
            child: Text(_label(l10n, option, hasSizes: hasSizes)),
          ),
      ],
    );
  }

  static String _label(AppLocalizations l10n, AppSort option, {required bool hasSizes}) {
    final text = switch (option) {
      AppSort.name => l10n.sortName,
      AppSort.totalSize => l10n.sortTotalSize,
      AppSort.cacheSize => l10n.sortCacheSize,
      AppSort.recentlyUpdated => l10n.sortRecentlyUpdated,
    };
    return option.needsSizes && !hasSizes ? '$text (${l10n.sortNeedsAccess})' : text;
  }
}
