import 'package:flutter/widgets.dart';

import '../../app/routes.dart';
import 'ui/catalogue_search_screen.dart';
import 'ui/plant_card_screen.dart';

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
    case AppRoutes.catalogue:
      return (_) => const CatalogueSearchScreen();
    case AppRoutes.plant:
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
