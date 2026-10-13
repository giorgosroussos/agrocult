<?php

use Tests\TestCase;

/*
| Feature tests boot the Laravel application; unit and architecture tests do not.
*/
pest()->extend(TestCase::class)->in('Feature');
