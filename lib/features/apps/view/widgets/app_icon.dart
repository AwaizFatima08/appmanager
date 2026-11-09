import 'package:appmanager/features/apps/application/app_providers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// An app's launcher icon, with a neutral placeholder while it loads.
class AppIcon extends ConsumerWidget {
  const AppIcon({required this.packageName, this.size = 40, super.key});

  final String packageName;
  final double size;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bytes = ref.watch(appIconProvider(packageName)).value;
    return SizedBox.square(
      dimension: size,
      child: bytes == null
          ? Icon(Icons.android, size: size * 0.8, color: Theme.of(context).colorScheme.outline)
          : Image.memory(bytes, gaplessPlayback: true, excludeFromSemantics: true),
    );
  }
}
