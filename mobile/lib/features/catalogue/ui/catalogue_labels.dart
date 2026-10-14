import 'package:flutter/widgets.dart';
import 'package:intl/intl.dart';

import '../../../l10n/generated/app_localizations.dart';

/// UI texts of the catalogue's enum values; an unknown value (from a newer
/// snapshot) is shown as it is.
extension CatalogueLabels on AppLocalizations {
  String activity(String value) => switch (value) {
    'sow_indoors' => activitySowIndoors,
    'sow_outdoors' => activitySowOutdoors,
    'transplant' => activityTransplant,
    'harvest' => activityHarvest,
    _ => value,
  };

  String sunLabel(String value) => switch (value) {
    'full_sun' => sunFullSun,
    'partial_shade' => sunPartialShade,
    'shade' => sunShade,
    _ => value,
  };

  String frostLabel(String value) => switch (value) {
    'tender' => frostTender,
    'half_hardy' => frostHalfHardy,
    'hardy' => frostHardy,
    _ => value,
  };

  String careAction(String value) => switch (value) {
    'water' => careWater,
    'fertilise' => careFertilise,
    'prune' => carePrune,
    'weed' => careWeed,
    'spray' => careSpray,
    'other' => careOther,
    _ => value,
  };
}

/// Month names and numbers in the UI language.
class CatalogueFormat {
  CatalogueFormat(BuildContext context)
    : _locale = Localizations.localeOf(context).toLanguageTag();

  final String _locale;

  String month(int month) =>
      DateFormat.LLLL(_locale).format(DateTime(2000, month));

  /// "March", or "October – January" across the new year.
  String months(int from, int to) =>
      from == to ? month(from) : '${month(from)} – ${month(to)}';

  String number(num value) => NumberFormat('#,##0.##', _locale).format(value);

  String celsius(num value) => '${number(value)} °C';

  String cm(num value) => '${number(value)} cm';
}
