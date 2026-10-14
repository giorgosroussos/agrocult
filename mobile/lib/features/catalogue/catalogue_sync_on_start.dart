import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'catalogue_providers.dart';

/// Starts the catalogue version check when the app starts (FLOW-003). The
/// app does not wait for it: the local catalogue is usable offline at once.
class CatalogueSyncOnStart extends ConsumerWidget {
  const CatalogueSyncOnStart({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Keeps the one-off check alive; its result is not shown.
    ref.watch(catalogueStartupSyncProvider);
    return child;
  }
}
