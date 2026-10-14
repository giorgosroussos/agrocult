<?php

return [
    'navigation_group' => 'Catalogue',

    'plants' => [
        'model_label' => 'plant',
        'plural_model_label' => 'Plants',
        'tabs' => [
            'structure' => 'Structured fields',
            'texts' => 'Texts',
            'aliases' => 'Aliases',
            'calendar' => 'Calendar',
            'companions' => 'Companions',
            'care' => 'Care intervals',
            'photos' => 'Photos',
            'sources' => 'Sources',
        ],
        'fields' => [
            'scientific_name' => 'Scientific name',
            'gbif_id' => 'GBIF id',
            'category' => 'Category',
            'temp_min_c' => 'Minimum temperature (°C)',
            'temp_opt_c' => 'Optimum temperature (°C)',
            'temp_max_c' => 'Maximum temperature (°C)',
            'water_need' => 'Water need (1-5)',
            'sun' => 'Sun',
            'soil_types' => 'Soil types',
            'ph_min' => 'Minimum pH',
            'ph_max' => 'Maximum pH',
            'frost_hardiness' => 'Frost hardiness',
            'propagation' => 'Propagation',
            'sow_depth_cm' => 'Sowing depth (cm)',
            'spacing_cm' => 'Spacing (cm)',
            'row_spacing_cm' => 'Row spacing (cm)',
            'days_to_harvest' => 'Days to harvest',
            'status' => 'Status',
            'name' => 'Name',
            'updated_at' => 'Updated',
            'published_at' => 'Published',
        ],
        'translation' => [
            'item' => 'Text',
            'lang' => 'Language',
            'name' => 'Name',
            'description' => 'Description',
            'planting' => 'Planting',
            'care' => 'Care',
            'seed_saving' => 'Seed saving',
            'tips' => 'Tips',
        ],
        'alias' => [
            'item' => 'Alias',
            'lang' => 'Language',
            'alias' => 'Alias',
            'kind' => 'Kind',
        ],
        'calendar' => [
            'item' => 'Calendar entry',
            'climate_zone' => 'Climate zone',
            'activity' => 'Activity',
            'month_from' => 'From month',
            'month_to' => 'To month',
        ],
        'companion' => [
            'item' => 'Companion',
            'other_plant' => 'Other plant',
            'relation' => 'Relation',
        ],
        'care_interval' => [
            'item' => 'Care interval',
            'action' => 'Action',
            'interval_days' => 'Every (days)',
            'month_from' => 'From month',
            'month_to' => 'To month',
        ],
        'photo' => [
            'item' => 'Photo',
            'file' => 'Photo (JPEG, PNG or WebP, at most 5 MB)',
            'credit' => 'Credit',
            'licence' => 'Licence',
            'source_url' => 'Source URL',
        ],
        'source' => [
            'item' => 'Source',
            'field' => 'Field',
            'source_name' => 'Source',
            'source_url' => 'Source URL',
            'licence' => 'Licence',
            'imported_at' => 'Imported',
        ],
        'missing_for_publishing' => 'Missing before publishing: :fields',
        'actions' => [
            'submit_for_review' => 'Submit for review',
            'publish' => 'Mark reviewed and publish',
            'publish_description' => 'The plant goes to the devices with the next catalogue sync.',
            'return_to_draft' => 'Return to draft',
            'archive' => 'Archive',
            'archive_description' => 'The plant is removed from the catalogue sent to devices.',
            'done' => 'The plant is now: :status',
            'rejected_transition' => 'A plant cannot change from ":from" to ":to".',
            'not_publishable' => 'The plant cannot be published. Missing: :fields',
        ],
    ],

    'statuses' => [
        'draft' => 'Draft',
        'in_review' => 'In review',
        'published' => 'Published',
        'archived' => 'Archived',
    ],

    'tip_statuses' => [
        'draft' => 'Draft',
        'published' => 'Published',
    ],

    'languages' => [
        'el' => 'Greek',
        'en' => 'English',
    ],

    'sun' => [
        'full_sun' => 'Full sun',
        'partial_shade' => 'Partial shade',
        'shade' => 'Shade',
    ],

    'frost_hardiness' => [
        'tender' => 'Tender',
        'half_hardy' => 'Half hardy',
        'hardy' => 'Hardy',
    ],

    'alias_kinds' => [
        'synonym' => 'Synonym',
        'local_name' => 'Local name',
        'greeklish' => 'Greeklish',
    ],

    'calendar_activities' => [
        'sow_indoors' => 'Sow indoors',
        'sow_outdoors' => 'Sow outdoors',
        'transplant' => 'Transplant',
        'harvest' => 'Harvest',
    ],

    'companion_relations' => [
        'good' => 'Good neighbour',
        'bad' => 'Bad neighbour',
    ],

    'care_actions' => [
        'water' => 'Water',
        'fertilise' => 'Fertilise',
        'prune' => 'Prune',
        'weed' => 'Weed',
        'spray' => 'Spray',
        'other' => 'Other',
    ],

    'categories' => [
        'model_label' => 'category',
        'plural_model_label' => 'Categories',
        'fields' => [
            'code' => 'Code',
            'name_el' => 'Name (Greek)',
            'name_en' => 'Name (English)',
            'parent' => 'Parent category',
            'sort_order' => 'Sort order',
            'plants_count' => 'Plants',
        ],
    ],

    'climate_zones' => [
        'model_label' => 'climate zone',
        'plural_model_label' => 'Climate zones',
        'fields' => [
            'code' => 'Code',
            'name_el' => 'Name (Greek)',
            'name_en' => 'Name (English)',
            'description' => 'Description',
            'rules' => 'Rules (JSON object)',
        ],
        'invalid_rules' => 'The rules must be a JSON object.',
    ],

    'tips' => [
        'model_label' => 'tip',
        'plural_model_label' => 'Tips',
        'fields' => [
            'text_el' => 'Text (Greek)',
            'text_en' => 'Text (English)',
            'month_from' => 'From month',
            'month_to' => 'To month',
            'climate_zone' => 'Climate zone',
            'plant' => 'Plant',
            'status' => 'Status',
        ],
    ],
];
