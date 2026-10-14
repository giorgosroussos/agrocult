import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../catalogue_providers.dart';
import '../../../app/routes.dart';
import '../data/catalogue_models.dart';
import 'catalogue_labels.dart';
import 'not_translated_label.dart';

/// The plant card (UC-004): identity, growing conditions, calendar,
/// planting, description, care, seed saving, tips and companions, in the UI
/// language, from the local catalogue (offline, no account needed).
class PlantCardScreen extends ConsumerWidget {
  const PlantCardScreen({super.key, required this.plantId, this.climateZoneId});

  final String plantId;

  /// Climate zone of the garden the card was opened from; its calendar is
  /// shown first. Without it every zone is shown in catalogue order.
  final String? climateZoneId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final card = ref.watch(
      plantCardProvider((plantId: plantId, lang: lang, zoneId: climateZoneId)),
    );

    return card.when(
      skipLoadingOnReload: true,
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator()),
      ),
      error: (_, _) => _message(context, l10n.catalogueLoadError),
      data: (plant) => plant == null
          ? _message(context, l10n.plantNotFound)
          : _PlantCardView(plant: plant, climateZoneId: climateZoneId),
    );
  }

  Widget _message(BuildContext context, String text) => Scaffold(
    appBar: AppBar(title: Text(AppLocalizations.of(context).catalogueTitle)),
    body: Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          text,
          key: const Key('plantCard.message'),
          textAlign: TextAlign.center,
        ),
      ),
    ),
  );
}

class _PlantCardView extends StatelessWidget {
  const _PlantCardView({required this.plant, this.climateZoneId});

  final PlantCardData plant;
  final String? climateZoneId;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final format = CatalogueFormat(context);

    return Scaffold(
      appBar: AppBar(title: Text(plant.name.text)),
      body: ListView(
        key: const Key('plantCard'),
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          // Identity
          Row(
            children: [
              Flexible(
                child: Text(
                  plant.name.text,
                  key: const Key('plantCard.name'),
                  style: theme.textTheme.headlineSmall,
                ),
              ),
              if (plant.name.isFallback) ...[
                const SizedBox(width: 8),
                const NotTranslatedLabel(),
              ],
            ],
          ),
          Text(
            plant.scientificName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontStyle: FontStyle.italic,
            ),
          ),
          if (plant.categoryName case final category?)
            _Fact(l10n.plantCategory, category),
          if (plant.otherNames.isNotEmpty)
            _Fact(l10n.plantOtherNames, plant.otherNames.join(', ')),

          _Section(
            'conditions',
            l10n.plantSectionConditions,
            children: [
              if (plant.tempMinC case final v?)
                _Fact(l10n.plantTempMin, format.celsius(v)),
              if (plant.tempOptC case final v?)
                _Fact(l10n.plantTempOpt, format.celsius(v)),
              if (plant.tempMaxC case final v?)
                _Fact(l10n.plantTempMax, format.celsius(v)),
              if (plant.waterNeed case final v?)
                _Fact(l10n.plantWaterNeed, l10n.plantWaterNeedValue(v)),
              if (plant.sun case final v?)
                _Fact(l10n.plantSun, l10n.sunLabel(v)),
              if (plant.soilTypes.isNotEmpty)
                _Fact(l10n.plantSoil, plant.soilTypes.join(', ')),
              if (plant.phMin != null || plant.phMax != null)
                _Fact(
                  l10n.plantPh,
                  [
                    plant.phMin,
                    plant.phMax,
                  ].whereType<double>().map(format.number).join(' – '),
                ),
              if (plant.frostHardiness case final v?)
                _Fact(l10n.plantFrost, l10n.frostLabel(v)),
            ],
          ),

          _Section(
            'calendar',
            l10n.plantSectionCalendar,
            empty: l10n.calendarEmpty,
            children: [
              for (final zone in plant.calendar)
                _ZoneCalendarView(zone: zone, format: format),
            ],
          ),

          _Section(
            'planting',
            l10n.plantSectionPlanting,
            children: [
              if (plant.propagation.isNotEmpty)
                _Fact(l10n.plantPropagation, plant.propagation.join(', ')),
              if (plant.sowDepthCm case final v?)
                _Fact(l10n.plantSowDepth, format.cm(v)),
              if (plant.spacingCm case final v?)
                _Fact(l10n.plantSpacing, format.cm(v)),
              if (plant.rowSpacingCm case final v?)
                _Fact(l10n.plantRowSpacing, format.cm(v)),
              if (plant.daysToHarvest case final v?)
                _Fact(l10n.plantDaysToHarvest, format.number(v)),
              if (plant.planting case final text?)
                _Text(text, key: const Key('plantCard.text.planting')),
            ],
          ),

          _Section(
            'description',
            l10n.plantSectionDescription,
            children: [
              if (plant.description case final text?)
                _Text(text, key: const Key('plantCard.text.description')),
            ],
          ),

          _Section(
            'care',
            l10n.plantSectionCare,
            children: [
              if (plant.care case final text?)
                _Text(text, key: const Key('plantCard.text.care')),
              for (final interval in plant.careIntervals)
                _Fact(
                  l10n.careAction(interval.action),
                  [
                    l10n.careEvery(interval.intervalDays),
                    if (interval.monthFrom != null && interval.monthTo != null)
                      '(${format.months(interval.monthFrom!, interval.monthTo!)})',
                  ].join(' '),
                ),
            ],
          ),

          _Section(
            'seedSaving',
            l10n.plantSectionSeedSaving,
            children: [
              if (plant.seedSaving case final text?)
                _Text(text, key: const Key('plantCard.text.seedSaving')),
            ],
          ),

          _Section(
            'tips',
            l10n.plantSectionTips,
            children: [
              if (plant.tips case final text?)
                _Text(text, key: const Key('plantCard.text.tips')),
              for (final tip in plant.plantTips)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text('• $tip'),
                ),
            ],
          ),

          _Section(
            'companions',
            l10n.plantSectionCompanions,
            children: [
              for (final good in [true, false])
                if (plant.companions.any((c) => c.isGood == good)) ...[
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      good ? l10n.companionsGood : l10n.companionsBad,
                      style: theme.textTheme.titleSmall,
                    ),
                  ),
                  Wrap(
                    spacing: 8,
                    children: [
                      for (final companion in plant.companions.where(
                        (c) => c.isGood == good,
                      ))
                        ActionChip(
                          key: Key('plantCard.companion.${companion.plantId}'),
                          avatar: Icon(
                            good ? Icons.thumb_up_outlined : Icons.block,
                            size: 18,
                          ),
                          label: Text(companion.name.text),
                          onPressed: () => Navigator.of(context).pushNamed(
                            AppRoutes.plant,
                            arguments: PlantCardArgs(
                              companion.plantId,
                              climateZoneId: climateZoneId,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
            ],
          ),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section(this.id, this.title, {required this.children, this.empty});

  final String id;
  final String title;
  final List<Widget> children;

  /// Shown when the section has no content.
  final String? empty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      key: Key('plantCard.section.$id'),
      padding: const EdgeInsets.only(top: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleLarge),
          const SizedBox(height: 8),
          if (children.isEmpty)
            Text(
              empty ?? AppLocalizations.of(context).plantNoInformation,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            )
          else
            ...children,
        ],
      ),
    );
  }
}

/// A label and its value.
class _Fact extends StatelessWidget {
  const _Fact(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            TextSpan(text: value),
          ],
        ),
        style: theme.textTheme.bodyMedium,
      ),
    );
  }
}

/// A catalogue text, marked when shown in another language.
class _Text extends StatelessWidget {
  const _Text(this.text, {super.key});

  final LocalText text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (text.isFallback) ...[
            const NotTranslatedLabel(),
            const SizedBox(height: 4),
          ],
          Text(text.text),
        ],
      ),
    );
  }
}

class _ZoneCalendarView extends StatelessWidget {
  const _ZoneCalendarView({required this.zone, required this.format});

  final ZoneCalendar zone;
  final CatalogueFormat format;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Card(
      key: Key('plantCard.zone.${zone.zoneId}'),
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Flexible(
                  child: Text(zone.zoneName, style: theme.textTheme.titleSmall),
                ),
                if (zone.isPreferred) ...[
                  const SizedBox(width: 8),
                  Text(
                    l10n.calendarYourZone,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ],
            ),
            for (final entry in zone.entries)
              _Fact(
                l10n.activity(entry.activity),
                format.months(entry.monthFrom, entry.monthTo),
              ),
          ],
        ),
      ),
    );
  }
}
