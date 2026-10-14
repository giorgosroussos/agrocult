import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/routes.dart';
import '../../../l10n/generated/app_localizations.dart';
import '../catalogue_providers.dart';
import '../catalogue_routes.dart';
import '../data/catalogue_models.dart';
import 'not_translated_label.dart';

/// Searches the local catalogue (UC-003): by name, alias or Greeklish in any
/// language, filtered by category and 'in season now'. Works offline and
/// without an account.
class CatalogueSearchScreen extends ConsumerStatefulWidget {
  const CatalogueSearchScreen({super.key});

  @override
  ConsumerState<CatalogueSearchScreen> createState() =>
      _CatalogueSearchScreenState();
}

class _CatalogueSearchScreenState extends ConsumerState<CatalogueSearchScreen> {
  final _search = TextEditingController();
  String _text = '';
  String? _categoryId;
  bool _inSeason = false;

  /// Shown while the next results load, so the list does not flicker.
  List<PlantListItem>? _lastResults;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final lang = Localizations.localeOf(context).languageCode;
    final query = PlantQuery(
      lang: lang,
      text: _text,
      categoryId: _categoryId,
      inSeason: _inSeason,
      inSeasonZones: _inSeason
          ? ref.watch(seasonClimateZonesProvider)
          : const {},
      month: _inSeason ? ref.watch(catalogueTodayProvider)().month : null,
    );
    final results = ref.watch(plantSearchProvider(query));
    final categories =
        ref.watch(catalogueCategoriesProvider(lang)).value ?? const [];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.catalogueTitle)),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: TextField(
              key: const Key('catalogue.search'),
              controller: _search,
              autofocus: false,
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: l10n.catalogueSearchHint,
                suffixIcon: _text.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        tooltip: MaterialLocalizations.of(
                          context,
                        ).deleteButtonTooltip,
                        onPressed: () {
                          _search.clear();
                          setState(() => _text = '');
                        },
                      ),
              ),
              onChanged: (value) => setState(() => _text = value),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _chip(
                  FilterChip(
                    key: const Key('catalogue.inSeason'),
                    label: Text(l10n.catalogueInSeasonFilter),
                    selected: _inSeason,
                    onSelected: (value) => setState(() => _inSeason = value),
                  ),
                ),
                _chip(
                  ChoiceChip(
                    key: const Key('catalogue.category.all'),
                    label: Text(l10n.catalogueAllCategories),
                    selected: _categoryId == null,
                    onSelected: (_) => setState(() => _categoryId = null),
                  ),
                ),
                for (final category in categories)
                  _chip(
                    ChoiceChip(
                      key: Key('catalogue.category.${category.code}'),
                      label: Text(category.name),
                      selected: _categoryId == category.id,
                      onSelected: (selected) => setState(
                        () => _categoryId = selected ? category.id : null,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Expanded(child: _results(context, results)),
        ],
      ),
    );
  }

  Widget _chip(Widget chip) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 4), child: chip);

  Widget _results(
    BuildContext context,
    AsyncValue<List<PlantListItem>> results,
  ) {
    final l10n = AppLocalizations.of(context);
    if (results.hasError && !results.isLoading) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(l10n.catalogueLoadError, textAlign: TextAlign.center),
        ),
      );
    }
    final items = results.value ?? _lastResults;
    if (results.hasValue) _lastResults = results.value;
    if (items == null) return const Center(child: CircularProgressIndicator());
    if (items.isEmpty) {
      return Center(
        key: const Key('catalogue.noResults'),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.catalogueNoResults,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(l10n.catalogueNoResultsHint, textAlign: TextAlign.center),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      key: const Key('catalogue.results'),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return ListTile(
          key: Key('catalogue.plant.${item.id}'),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  item.name.text,
                  key: const Key('catalogue.plantName'),
                ),
              ),
              if (item.name.isFallback) ...[
                const SizedBox(width: 8),
                const NotTranslatedLabel(),
              ],
            ],
          ),
          subtitle: Text(
            item.scientificName,
            style: const TextStyle(fontStyle: FontStyle.italic),
          ),
          trailing: const Icon(Icons.chevron_right),
          onTap: () => Navigator.of(
            context,
          ).pushNamed(AppRoutes.plant, arguments: PlantCardArgs(item.id)),
        );
      },
    );
  }
}
