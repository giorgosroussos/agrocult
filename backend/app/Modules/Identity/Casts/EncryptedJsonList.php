<?php

namespace App\Modules\Identity\Casts;

use Illuminate\Contracts\Database\Eloquent\CastsAttributes;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Support\Facades\Crypt;
use UnexpectedValueException;

/**
 * A list of strings encrypted at rest in a jsonb column.
 *
 * The whole list is encrypted with the application key and stored as a single
 * JSON string, so the column stays valid jsonb while its content is unreadable
 * without the key.
 *
 * @implements CastsAttributes<list<string>|null, array<string>|null>
 */
class EncryptedJsonList implements CastsAttributes
{
    /**
     * @param  array<string, mixed>  $attributes
     * @return list<string>|null
     */
    public function get(Model $model, string $key, mixed $value, array $attributes): ?array
    {
        if ($value === null) {
            return null;
        }

        $ciphertext = json_decode((string) $value, true);

        if (! is_string($ciphertext)) {
            throw new UnexpectedValueException("The {$key} attribute is not an encrypted value.");
        }

        $list = json_decode(Crypt::decryptString($ciphertext), true);

        return is_array($list) ? array_values(array_map('strval', $list)) : null;
    }

    /**
     * @param  array<string>|null  $value
     * @param  array<string, mixed>  $attributes
     */
    public function set(Model $model, string $key, mixed $value, array $attributes): ?string
    {
        if ($value === null) {
            return null;
        }

        return json_encode(Crypt::encryptString((string) json_encode(array_values($value))), JSON_THROW_ON_ERROR);
    }
}
