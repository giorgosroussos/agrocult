<?php

namespace App\Modules\Catalogue\Enums;

/**
 * ENT-Plant.status and its state model (design/model/data.yaml):
 * initial draft; draft -> in_review, in_review -> draft, in_review -> published,
 * published -> draft, published -> archived.
 */
enum PlantStatus: string
{
    case Draft = 'draft';
    case InReview = 'in_review';
    case Published = 'published';
    case Archived = 'archived';

    public const INITIAL = self::Draft;

    /**
     * @return list<self>
     */
    public function allowedTransitions(): array
    {
        return match ($this) {
            self::Draft => [self::InReview],
            self::InReview => [self::Draft, self::Published],
            self::Published => [self::Draft, self::Archived],
            self::Archived => [],
        };
    }

    public function canTransitionTo(self $to): bool
    {
        return in_array($to, $this->allowedTransitions(), true);
    }
}
