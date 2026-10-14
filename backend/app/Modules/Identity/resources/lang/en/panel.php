<?php

return [
    'roles' => [
        'gardener' => 'Gardener',
        'curator' => 'Curator',
        'admin' => 'Admin',
    ],
    'users' => [
        'model_label' => 'account',
        'plural_model_label' => 'Accounts',
        'columns' => [
            'email' => 'Email',
            'role' => 'Role',
            'mfa' => 'Two-factor authentication',
            'created_at' => 'Created',
        ],
        'reset_mfa' => [
            'label' => 'Reset two-factor authentication',
            'description' => 'The account must set up an authenticator app again at its next sign-in to the panel. Its recovery codes stop working.',
            'done' => 'Two-factor authentication has been reset.',
        ],
    ],
];
