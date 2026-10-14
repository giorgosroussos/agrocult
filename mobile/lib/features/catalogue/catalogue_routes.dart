import 'package:flutter/widgets.dart';

import 'ui/catalogue_search_screen.dart';
import 'ui/plant_card_screen.dart';

/// Route names of the catalogue's screens. How the app shell registers them
/// and links to the search is open (CR-P2-T6-1).
abstract final class CatalogueRoutes {
  /// Catalogue search (UC-003); no account needed.
  static const search = '/catalogue';

  /// Plant card (UC-004); no account needed. Argument: the plant id (String)
  /// or [PlantCardArgs].
  static const plant = '/plant';
}

/// Opens a plant card; [climateZoneId] is the climate zone of the garden it
/// is opened from, whose calendar is then shown first (UC-004).
class PlantCardArgs {
  const PlantCardArgs(this.plantId, {this.climateZoneId});

  final String plantId;
  final String? climateZoneId;
}

/// The catalogue's screens (a `FeatureRoutes` of the app router). None of
/// them needs an account (SCOPE-002).
WidgetBuilder? catalogueRoutes(RouteSettings settings) {
  final args = settings.arguments;
  switch (settings.name) {
    case CatalogueRoutes.search:
      return (_) => const CatalogueSearchScreen();
    case CatalogueRoutes.plant:
      if (args is PlantCardArgs) {
        return (_) => PlantCardScreen(
          plantId: args.plantId,
          climateZoneId: args.climateZoneId,
        );
      }
      if (args is String) return (_) => PlantCardScreen(plantId: args);
  }
  return null;
}
