/// What the search list and the plant card show, read from the local
/// catalogue in the UI language (UC-003, UC-004).
library;

/// A text in [lang]. [isFallback] is true when the UI language had no text
/// and another language is shown instead (marked as not translated).
class LocalText {
  const LocalText(this.text, this.lang, {required this.isFallback});

  final String text;
  final String lang;
  final bool isFallback;

  @override
  bool operator ==(Object other) =>
      other is LocalText &&
      other.text == text &&
      other.lang == lang &&
      other.isFallback == isFallback;

  @override
  int get hashCode => Object.hash(text, lang, isFallback);

  @override
  String toString() =>
      'LocalText($lang${isFallback ? ', fallback' : ''}: '
      '$text)';
}

/// A curator-managed plant category (never hard-coded in the app, DATA-004).
class CategoryItem {
  const CategoryItem({
    required this.id,
    required this.code,
    required this.name,
    this.parentId,
  });

  final String id;
  final String code;
  final String name;
  final String? parentId;
}

/// What the user searches for. [lang] is the UI language; [inSeasonZones]
/// limits 'in season now' to these climate zones (any zone when empty).
class PlantQuery {
  const PlantQuery({
    required this.lang,
    this.text = '',
    this.categoryId,
    this.inSeason = false,
    this.inSeasonZones = const {},
    this.month,
  });

  final String lang;
  final String text;
  final String? categoryId;
  final bool inSeason;
  final Set<String> inSeasonZones;

  /// Month (1-12) for 'in season now'; required when [inSeason] is set.
  final int? month;

  @override
  bool operator ==(Object other) =>
      other is PlantQuery &&
      other.lang == lang &&
      other.text == text &&
      other.categoryId == categoryId &&
      other.inSeason == inSeason &&
      other.month == month &&
      other.inSeasonZones.length == inSeasonZones.length &&
      other.inSeasonZones.containsAll(inSeasonZones);

  @override
  int get hashCode => Object.hash(
    lang,
    text,
    categoryId,
    inSeason,
    month,
    Object.hashAllUnordered(inSeasonZones),
  );
}

/// One plant in the search results.
class PlantListItem {
  const PlantListItem({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.categoryId,
  });

  final String id;
  final LocalText name;
  final String scientificName;
  final String categoryId;
}

/// Months of one calendar activity (sow_indoors, sow_outdoors, transplant,
/// harvest); [monthFrom] > [monthTo] runs across the new year.
class CalendarEntry {
  const CalendarEntry({
    required this.activity,
    required this.monthFrom,
    required this.monthTo,
  });

  final String activity;
  final int monthFrom;
  final int monthTo;
}

/// The calendar of a plant in one climate zone.
class ZoneCalendar {
  const ZoneCalendar({
    required this.zoneId,
    required this.zoneName,
    required this.isPreferred,
    required this.entries,
  });

  final String zoneId;
  final String zoneName;

  /// The zone of the garden the card was opened from.
  final bool isPreferred;
  final List<CalendarEntry> entries;
}

class CareIntervalItem {
  const CareIntervalItem({
    required this.action,
    required this.intervalDays,
    this.monthFrom,
    this.monthTo,
  });

  final String action;
  final int intervalDays;
  final int? monthFrom;
  final int? monthTo;
}

class CompanionItem {
  const CompanionItem({
    required this.plantId,
    required this.name,
    required this.isGood,
  });

  final String plantId;
  final LocalText name;
  final bool isGood;
}

/// Provenance of a catalogue fact or photo (SCOPE-001).
class SourceItem {
  const SourceItem({
    required this.name,
    required this.licence,
    this.field,
    this.url,
  });

  final String name;
  final String licence;
  final String? field;
  final String? url;
}

/// Everything the plant card shows.
class PlantCardData {
  const PlantCardData({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.otherNames,
    this.categoryName,
    this.tempMinC,
    this.tempOptC,
    this.tempMaxC,
    this.waterNeed,
    this.sun,
    this.soilTypes = const [],
    this.phMin,
    this.phMax,
    this.frostHardiness,
    this.propagation = const [],
    this.sowDepthCm,
    this.spacingCm,
    this.rowSpacingCm,
    this.daysToHarvest,
    this.calendar = const [],
    this.description,
    this.planting,
    this.care,
    this.seedSaving,
    this.tips,
    this.careIntervals = const [],
    this.plantTips = const [],
    this.companions = const [],
    this.sources = const [],
  });

  final String id;
  final LocalText name;
  final String scientificName;

  /// Aliases and the names in other languages.
  final List<String> otherNames;
  final String? categoryName;

  final double? tempMinC;
  final double? tempOptC;
  final double? tempMaxC;

  /// 1 (little) to 5 (much).
  final int? waterNeed;
  final String? sun;
  final List<String> soilTypes;
  final double? phMin;
  final double? phMax;
  final String? frostHardiness;

  final List<String> propagation;
  final double? sowDepthCm;
  final int? spacingCm;
  final int? rowSpacingCm;
  final int? daysToHarvest;

  /// Preferred zone first, then the other zones.
  final List<ZoneCalendar> calendar;

  final LocalText? description;
  final LocalText? planting;
  final LocalText? care;
  final LocalText? seedSaving;
  final LocalText? tips;

  final List<CareIntervalItem> careIntervals;

  /// Published tips tied to this plant, in the UI language.
  final List<String> plantTips;
  final List<CompanionItem> companions;
  final List<SourceItem> sources;
}
