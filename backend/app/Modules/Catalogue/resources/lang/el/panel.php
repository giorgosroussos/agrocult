<?php

return [
    'navigation_group' => 'Κατάλογος',

    'plants' => [
        'model_label' => 'φυτό',
        'plural_model_label' => 'Φυτά',
        'tabs' => [
            'structure' => 'Δομημένα πεδία',
            'texts' => 'Κείμενα',
            'aliases' => 'Συνώνυμα',
            'calendar' => 'Ημερολόγιο',
            'companions' => 'Συγκαλλιέργεια',
            'care' => 'Διαστήματα φροντίδας',
            'photos' => 'Φωτογραφίες',
            'sources' => 'Πηγές',
        ],
        'fields' => [
            'scientific_name' => 'Επιστημονική ονομασία',
            'gbif_id' => 'Αναγνωριστικό GBIF',
            'category' => 'Κατηγορία',
            'temp_min_c' => 'Ελάχιστη θερμοκρασία (°C)',
            'temp_opt_c' => 'Βέλτιστη θερμοκρασία (°C)',
            'temp_max_c' => 'Μέγιστη θερμοκρασία (°C)',
            'water_need' => 'Ανάγκη σε νερό (1-5)',
            'sun' => 'Ηλιοφάνεια',
            'soil_types' => 'Τύποι εδάφους',
            'ph_min' => 'Ελάχιστο pH',
            'ph_max' => 'Μέγιστο pH',
            'frost_hardiness' => 'Αντοχή στον παγετό',
            'propagation' => 'Πολλαπλασιασμός',
            'sow_depth_cm' => 'Βάθος σποράς (cm)',
            'spacing_cm' => 'Απόσταση φύτευσης (cm)',
            'row_spacing_cm' => 'Απόσταση γραμμών (cm)',
            'days_to_harvest' => 'Ημέρες έως τη συγκομιδή',
            'status' => 'Κατάσταση',
            'name' => 'Όνομα',
            'updated_at' => 'Τελευταία αλλαγή',
            'published_at' => 'Δημοσίευση',
        ],
        'translation' => [
            'item' => 'Κείμενο',
            'lang' => 'Γλώσσα',
            'name' => 'Όνομα',
            'description' => 'Περιγραφή',
            'planting' => 'Φύτευση',
            'care' => 'Φροντίδα',
            'seed_saving' => 'Διατήρηση σπόρων',
            'tips' => 'Συμβουλές',
        ],
        'alias' => [
            'item' => 'Συνώνυμο',
            'lang' => 'Γλώσσα',
            'alias' => 'Συνώνυμο',
            'kind' => 'Είδος',
        ],
        'calendar' => [
            'item' => 'Εγγραφή ημερολογίου',
            'climate_zone' => 'Κλιματική ζώνη',
            'activity' => 'Εργασία',
            'month_from' => 'Από μήνα',
            'month_to' => 'Έως μήνα',
        ],
        'companion' => [
            'item' => 'Γειτονικό φυτό',
            'other_plant' => 'Άλλο φυτό',
            'relation' => 'Σχέση',
        ],
        'care_interval' => [
            'item' => 'Διάστημα φροντίδας',
            'action' => 'Εργασία',
            'interval_days' => 'Κάθε (ημέρες)',
            'month_from' => 'Από μήνα',
            'month_to' => 'Έως μήνα',
        ],
        'photo' => [
            'item' => 'Φωτογραφία',
            'file' => 'Φωτογραφία (JPEG, PNG ή WebP, έως 5 MB)',
            'credit' => 'Δημιουργός',
            'licence' => 'Άδεια χρήσης',
            'source_url' => 'URL πηγής',
        ],
        'source' => [
            'item' => 'Πηγή',
            'field' => 'Πεδίο',
            'source_name' => 'Πηγή',
            'source_url' => 'URL πηγής',
            'licence' => 'Άδεια χρήσης',
            'imported_at' => 'Εισαγωγή',
        ],
        'missing_for_publishing' => 'Λείπουν για τη δημοσίευση: :fields',
        'actions' => [
            'submit_for_review' => 'Υποβολή για έλεγχο',
            'publish' => 'Έλεγχος και δημοσίευση',
            'publish_description' => 'Το φυτό φτάνει στις συσκευές με τον επόμενο συγχρονισμό του καταλόγου.',
            'return_to_draft' => 'Επιστροφή σε πρόχειρο',
            'archive' => 'Αρχειοθέτηση',
            'archive_description' => 'Το φυτό αφαιρείται από τον κατάλογο που στέλνεται στις συσκευές.',
            'done' => 'Το φυτό είναι τώρα: :status',
            'rejected_transition' => 'Ένα φυτό δεν μπορεί να αλλάξει από «:from» σε «:to».',
            'not_publishable' => 'Το φυτό δεν μπορεί να δημοσιευτεί. Λείπουν: :fields',
        ],
    ],

    'statuses' => [
        'draft' => 'Πρόχειρο',
        'in_review' => 'Σε έλεγχο',
        'published' => 'Δημοσιευμένο',
        'archived' => 'Αρχειοθετημένο',
    ],

    'tip_statuses' => [
        'draft' => 'Πρόχειρο',
        'published' => 'Δημοσιευμένο',
    ],

    'languages' => [
        'el' => 'Ελληνικά',
        'en' => 'Αγγλικά',
    ],

    'sun' => [
        'full_sun' => 'Πλήρης ήλιος',
        'partial_shade' => 'Ημισκιά',
        'shade' => 'Σκιά',
    ],

    'frost_hardiness' => [
        'tender' => 'Ευαίσθητο',
        'half_hardy' => 'Μέτρια ανθεκτικό',
        'hardy' => 'Ανθεκτικό',
    ],

    'alias_kinds' => [
        'synonym' => 'Συνώνυμο',
        'local_name' => 'Τοπική ονομασία',
        'greeklish' => 'Greeklish',
    ],

    'calendar_activities' => [
        'sow_indoors' => 'Σπορά σε σπορείο',
        'sow_outdoors' => 'Σπορά στο έδαφος',
        'transplant' => 'Μεταφύτευση',
        'harvest' => 'Συγκομιδή',
    ],

    'companion_relations' => [
        'good' => 'Καλός γείτονας',
        'bad' => 'Κακός γείτονας',
    ],

    'care_actions' => [
        'water' => 'Πότισμα',
        'fertilise' => 'Λίπανση',
        'prune' => 'Κλάδεμα',
        'weed' => 'Βοτάνισμα',
        'spray' => 'Ψεκασμός',
        'other' => 'Άλλο',
    ],

    'categories' => [
        'model_label' => 'κατηγορία',
        'plural_model_label' => 'Κατηγορίες',
        'fields' => [
            'code' => 'Κωδικός',
            'name_el' => 'Όνομα (ελληνικά)',
            'name_en' => 'Όνομα (αγγλικά)',
            'parent' => 'Γονική κατηγορία',
            'sort_order' => 'Σειρά ταξινόμησης',
            'plants_count' => 'Φυτά',
        ],
    ],

    'climate_zones' => [
        'model_label' => 'κλιματική ζώνη',
        'plural_model_label' => 'Κλιματικές ζώνες',
        'fields' => [
            'code' => 'Κωδικός',
            'name_el' => 'Όνομα (ελληνικά)',
            'name_en' => 'Όνομα (αγγλικά)',
            'description' => 'Περιγραφή',
            'rules' => 'Κανόνες (αντικείμενο JSON)',
        ],
        'invalid_rules' => 'Οι κανόνες πρέπει να είναι αντικείμενο JSON.',
    ],

    'tips' => [
        'model_label' => 'συμβουλή',
        'plural_model_label' => 'Συμβουλές',
        'fields' => [
            'text_el' => 'Κείμενο (ελληνικά)',
            'text_en' => 'Κείμενο (αγγλικά)',
            'month_from' => 'Από μήνα',
            'month_to' => 'Έως μήνα',
            'climate_zone' => 'Κλιματική ζώνη',
            'plant' => 'Φυτό',
            'status' => 'Κατάσταση',
        ],
    ],
];
