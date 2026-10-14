import 'dart:convert';

import 'package:drift/drift.dart';

import '../search/search_text.dart';
import 'catalogue_database.dart';
import 'catalogue_models.dart';

/// Reads search results and plant cards from the local catalogue (UC-003,
/// UC-004). Everything comes from the snapshot on the device: no account and
/// no network are needed. The snapshot holds only published plants
/// (ARCH-003), so nothing else can ever be found or opened.
class CatalogueRepository {
  CatalogueRepository(this._db);

  final CatalogueDatabase _db;

  /// Calendar activities that make a plant 'in season now' when their months
  /// include the current month; harvest never counts (UC-003).
  static const seasonActivities = ['sow_indoors', 'sow_outdoors', 'transplant'];

  /// The languages a catalogue text can have, in fallback order.
  static const languages = ['el', 'en'];

  /// Categories in curator order, named in [lang].
  Future<List<CategoryItem>> categories(String lang) async {
    final rows =
        await (_db.select(_db.categories)..orderBy([
              (c) =>
                  OrderingTerm(expression: c.sortOrder, nulls: NullsOrder.last),
              (c) => OrderingTerm(expression: c.code),
            ]))
            .get();
    return [
      for (final row in rows)
        CategoryItem(
          id: row.id,
          code: row.code,
          name: lang == 'el' ? row.nameEl : row.nameEn,
          parentId: row.parentId,
        ),
    ];
  }

  /// Plants matching [query], sorted by their name in the UI language.
  Future<List<PlantListItem>> search(PlantQuery query) async {
    final where = <String>[];
    final variables = <Variable<Object>>[];

    final match = ftsMatchExpression(query.text);
    if (match != null) {
      where.add(
        'p.id IN (SELECT plant_id FROM plant_search '
        'WHERE plant_search MATCH ?)',
      );
      variables.add(Variable.withString(match));
    }

    final categoryId = query.categoryId;
    if (categoryId != null) {
      final ids = await _withSubcategories(categoryId);
      where.add('p.category_id IN (${_marks(ids.length)})');
      variables.addAll(ids.map(Variable.withString));
    }

    if (query.inSeason) {
      final month = query.month;
      if (month == null || month < 1 || month > 12) {
        throw ArgumentError.value(month, 'month', 'needed for in season now');
      }
      final zones = query.inSeasonZones.toList();
      where.add(
        'EXISTS (SELECT 1 FROM plant_calendars c WHERE c.plant_id = p.id '
        'AND c.activity IN (${_marks(seasonActivities.length)}) '
        '${zones.isEmpty ? '' : 'AND c.climate_zone_id IN (${_marks(zones.length)}) '}'
        'AND ((c.month_from <= c.month_to AND ? BETWEEN c.month_from AND c.month_to) '
        'OR (c.month_from > c.month_to AND (? >= c.month_from OR ? <= c.month_to))))',
      );
      variables
        ..addAll(seasonActivities.map(Variable.withString))
        ..addAll(zones.map(Variable.withString))
        ..addAll(List.filled(3, Variable.withInt(month)));
    }

    final rows = await _db
        .customSelect(
          'SELECT p.id, p.scientific_name, p.category_id FROM plants p'
          '${where.isEmpty ? '' : ' WHERE ${where.join(' AND ')}'}',
          variables: variables,
        )
        .get();
    if (rows.isEmpty) return const [];

    final names = await _names(
      rows.map((r) => r.read<String>('id')).toList(),
      query.lang,
    );
    final items = [
      for (final row in rows)
        PlantListItem(
          id: row.read<String>('id'),
          name:
              names[row.read<String>('id')] ??
              LocalText(
                row.read<String>('scientific_name'),
                'la',
                isFallback: false,
              ),
          scientificName: row.read<String>('scientific_name'),
          categoryId: row.read<String>('category_id'),
        ),
    ];
    final keys = {
      for (final item in items) item.id: searchWords(item.name.text).join(' '),
    };
    items.sort((a, b) => keys[a.id]!.compareTo(keys[b.id]!));
    return items;
  }

  /// The card of plant [id] in [lang]; null when the plant is not in the
  /// local catalogue. The calendar lists [preferredZoneId] first.
  Future<PlantCardData?> plantCard(
    String id, {
    required String lang,
    String? preferredZoneId,
  }) async {
    final plant = await (_db.select(
      _db.plants,
    )..where((p) => p.id.equals(id))).getSingleOrNull();
    if (plant == null) return null;

    final translations = await (_db.select(
      _db.plantTranslations,
    )..where((t) => t.plantId.equals(id))).get();
    final ordered = _inFallbackOrder(translations, lang);
    LocalText? text(String? Function(CataloguePlantTranslation) field) {
      for (final row in ordered) {
        final value = field(row)?.trim();
        if (value != null && value.isNotEmpty) {
          return LocalText(value, row.lang, isFallback: row.lang != lang);
        }
      }
      return null;
    }

    final name =
        text((t) => t.name) ??
        LocalText(plant.scientificName, 'la', isFallback: false);

    final aliases = await (_db.select(
      _db.plantAliases,
    )..where((a) => a.plantId.equals(id))).get();
    final otherNames = <String>[];
    for (final candidate in [
      ...ordered.map((t) => t.name),
      ...aliases.map((a) => a.alias),
    ]) {
      if (candidate != name.text && !otherNames.contains(candidate)) {
        otherNames.add(candidate);
      }
    }

    final category = await (_db.select(
      _db.categories,
    )..where((c) => c.id.equals(plant.categoryId))).getSingleOrNull();

    return PlantCardData(
      id: plant.id,
      name: name,
      scientificName: plant.scientificName,
      otherNames: otherNames,
      categoryName: category == null
          ? null
          : (lang == 'el' ? category.nameEl : category.nameEn),
      tempMinC: plant.tempMinC,
      tempOptC: plant.tempOptC,
      tempMaxC: plant.tempMaxC,
      waterNeed: plant.waterNeed,
      sun: plant.sun,
      soilTypes: _stringList(plant.soilTypes),
      phMin: plant.phMin,
      phMax: plant.phMax,
      frostHardiness: plant.frostHardiness,
      propagation: _stringList(plant.propagation),
      sowDepthCm: plant.sowDepthCm,
      spacingCm: plant.spacingCm,
      rowSpacingCm: plant.rowSpacingCm,
      daysToHarvest: plant.daysToHarvest,
      calendar: await _calendar(id, lang, preferredZoneId),
      description: text((t) => t.description),
      planting: text((t) => t.planting),
      care: text((t) => t.care),
      seedSaving: text((t) => t.seedSaving),
      tips: text((t) => t.tips),
      careIntervals: await _careIntervals(id),
      plantTips: await _plantTips(id, lang),
      companions: await _companions(id, lang),
    );
  }

  Future<List<ZoneCalendar>> _calendar(
    String plantId,
    String lang,
    String? preferredZoneId,
  ) async {
    final rows = await (_db.select(
      _db.plantCalendars,
    )..where((c) => c.plantId.equals(plantId))).get();
    if (rows.isEmpty) return const [];
    final zones = await (_db.select(
      _db.climateZones,
    )..orderBy([(z) => OrderingTerm(expression: z.code)])).get();
    const activityOrder = [
      'sow_indoors',
      'sow_outdoors',
      'transplant',
      'harvest',
    ];
    int rank(String activity) {
      final index = activityOrder.indexOf(activity);
      return index < 0 ? activityOrder.length : index;
    }

    final calendars = <ZoneCalendar>[];
    for (final zone in zones) {
      final entries =
          rows
              .where((r) => r.climateZoneId == zone.id)
              .map(
                (r) => CalendarEntry(
                  activity: r.activity,
                  monthFrom: r.monthFrom,
                  monthTo: r.monthTo,
                ),
              )
              .toList()
            ..sort((a, b) {
              final byActivity = rank(a.activity).compareTo(rank(b.activity));
              return byActivity != 0
                  ? byActivity
                  : a.monthFrom.compareTo(b.monthFrom);
            });
      if (entries.isEmpty) continue;
      calendars.add(
        ZoneCalendar(
          zoneId: zone.id,
          zoneName: lang == 'el' ? zone.nameEl : zone.nameEn,
          isPreferred: zone.id == preferredZoneId,
          entries: entries,
        ),
      );
    }
    // The garden's zone first; the others keep their order.
    final preferred = calendars.where((c) => c.isPreferred).toList();
    return [...preferred, ...calendars.where((c) => !c.isPreferred)];
  }

  Future<List<CareIntervalItem>> _careIntervals(String plantId) async {
    final rows =
        await (_db.select(_db.careIntervals)
              ..where((c) => c.plantId.equals(plantId))
              ..orderBy([(c) => OrderingTerm(expression: c.intervalDays)]))
            .get();
    return [
      for (final row in rows)
        CareIntervalItem(
          action: row.action,
          intervalDays: row.intervalDays,
          monthFrom: row.monthFrom,
          monthTo: row.monthTo,
        ),
    ];
  }

  Future<List<String>> _plantTips(String plantId, String lang) async {
    final rows =
        await (_db.select(_db.tips)
              ..where((t) => t.plantId.equals(plantId))
              ..orderBy([(t) => OrderingTerm(expression: t.id)]))
            .get();
    return [for (final row in rows) lang == 'el' ? row.textEl : row.textEn];
  }

  Future<List<CompanionItem>> _companions(String plantId, String lang) async {
    final rows = await (_db.select(
      _db.companions,
    )..where((c) => c.plantId.equals(plantId))).get();
    if (rows.isEmpty) return const [];
    final names = await _names(rows.map((r) => r.otherPlantId).toList(), lang);
    final items = [
      for (final row in rows)
        if (names[row.otherPlantId] case final name?)
          CompanionItem(
            plantId: row.otherPlantId,
            name: name,
            isGood: row.relation == 'good',
          ),
    ]..sort((a, b) => a.name.text.compareTo(b.name.text));
    return items;
  }

  /// Name of each plant in [lang], or in another language as a fallback.
  Future<Map<String, LocalText>> _names(List<String> ids, String lang) async {
    final rows = await (_db.select(
      _db.plantTranslations,
    )..where((t) => t.plantId.isIn(ids))).get();
    final byPlant = <String, List<CataloguePlantTranslation>>{};
    for (final row in rows) {
      byPlant.putIfAbsent(row.plantId, () => []).add(row);
    }
    return {
      for (final entry in byPlant.entries)
        if (_inFallbackOrder(entry.value, lang).firstOrNull case final best?)
          entry.key: LocalText(
            best.name,
            best.lang,
            isFallback: best.lang != lang,
          ),
    };
  }

  /// [lang] first, then the other languages in [languages] order.
  static List<CataloguePlantTranslation> _inFallbackOrder(
    List<CataloguePlantTranslation> rows,
    String lang,
  ) {
    int rank(String rowLang) {
      if (rowLang == lang) return -1;
      final index = languages.indexOf(rowLang);
      return index < 0 ? languages.length : index;
    }

    return [...rows]..sort((a, b) => rank(a.lang).compareTo(rank(b.lang)));
  }

  Future<List<String>> _withSubcategories(String categoryId) async {
    final all = await _db.select(_db.categories).get();
    final ids = {categoryId};
    var added = true;
    while (added) {
      added = false;
      for (final category in all) {
        if (category.parentId != null &&
            ids.contains(category.parentId) &&
            ids.add(category.id)) {
          added = true;
        }
      }
    }
    return ids.toList();
  }

  static String _marks(int count) => List.filled(count, '?').join(', ');

  /// A JSON list of strings (soil types, propagation); anything else is
  /// shown as nothing.
  static List<String> _stringList(String? json) {
    if (json == null) return const [];
    try {
      final decoded = jsonDecode(json);
      if (decoded is List) {
        return [
          for (final value in decoded)
            if (value is String && value.trim().isNotEmpty) value.trim(),
        ];
      }
    } on FormatException {
      // Not JSON: nothing to show.
    }
    return const [];
  }
}
