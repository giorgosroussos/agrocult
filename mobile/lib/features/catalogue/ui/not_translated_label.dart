import 'package:flutter/material.dart';

import '../../../l10n/generated/app_localizations.dart';

/// Marks a catalogue text shown in another language because the UI language
/// has none (UC-004).
class NotTranslatedLabel extends StatelessWidget {
  const NotTranslatedLabel({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      key: const Key('catalogue.notTranslated'),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        AppLocalizations.of(context).notTranslated,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSecondaryContainer,
        ),
      ),
    );
  }
}
