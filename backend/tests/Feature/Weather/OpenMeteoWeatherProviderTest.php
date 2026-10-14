<?php

use App\Modules\Weather\Exceptions\WeatherUnavailable;
use App\Modules\Weather\Provider\DailyForecast;
use App\Modules\Weather\Provider\DailyWeather;
use App\Modules\Weather\Provider\FakeWeatherProvider;
use App\Modules\Weather\Provider\OpenMeteoWeatherProvider;
use App\Modules\Weather\Provider\WeatherProvider;
use Carbon\CarbonImmutable;
use Illuminate\Http\Client\ConnectionException;
use Illuminate\Http\Client\Request;
use Illuminate\Support\Facades\Http;

beforeEach(function () {
    Http::preventStrayRequests();
    config([
        'weather.open_meteo.base_url' => 'https://forecast.test/',
        'weather.open_meteo.archive_url' => 'https://archive.test',
    ]);
});

function dailyJson(array $dates): array
{
    return ['daily' => [
        'time' => $dates,
        'temperature_2m_min' => array_fill(0, count($dates), -1.5),
        'temperature_2m_max' => array_fill(0, count($dates), 9.0),
        'precipitation_sum' => array_fill(0, count($dates), 2.4),
    ]];
}

/**
 * Calls every EXT-002 operation once.
 */
function callEveryOperation(WeatherProvider $weather): void
{
    $weather->elevation(37.98, 23.73);
    $weather->history(37.98, 23.73, CarbonImmutable::parse('2016-01-01'), CarbonImmutable::parse('2016-01-02'));
    $weather->forecast(37.98, 23.73, 2);
}

it('uses a 10 s timeout on every EXT-002 call (INT-002)', function () {
    $timeouts = [];

    Http::fake(function (Request $request, array $options) use (&$timeouts) {
        $timeouts[parse_url($request->url(), PHP_URL_PATH)] = $options['timeout'] ?? null;

        return str_contains($request->url(), 'elevation')
            ? Http::response(['elevation' => [112.0]])
            : Http::response(dailyJson(['2016-01-01', '2016-01-02']));
    });

    callEveryOperation(new OpenMeteoWeatherProvider);

    expect($timeouts)->toBe([
        '/v1/elevation' => 10,
        '/v1/archive' => 10,
        '/v1/forecast' => 10,
    ]);
});

it('maps elevation, history and forecast and sends only coordinates rounded to 2 decimals', function () {
    Http::fake([
        'forecast.test/v1/elevation*' => Http::response(['elevation' => [112.6]]),
        '*' => Http::response(dailyJson(['2016-01-01', '2016-01-02'])),
    ]);

    $weather = new OpenMeteoWeatherProvider;

    expect($weather->elevation(37.98412, 23.72754))->toBe(113);

    $history = $weather->history(37.98412, 23.72754, CarbonImmutable::parse('2016-01-01'), CarbonImmutable::parse('2016-01-02'));
    expect($history)->toHaveCount(2)
        ->and($history[0])->toBeInstanceOf(DailyWeather::class)
        ->and($history[0]->date->toDateString())->toBe('2016-01-01')
        ->and($history[0]->tempMinC)->toBe(-1.5)
        ->and($history[0]->tempMaxC)->toBe(9.0)
        ->and($history[0]->rainMm)->toBe(2.4);

    $forecast = $weather->forecast(37.98412, 23.72754, 2);
    expect($forecast[1])->toBeInstanceOf(DailyForecast::class)
        ->and($forecast[1]->date->toDateString())->toBe('2016-01-02');

    Http::assertSent(fn (Request $request) => str_starts_with($request->url(), 'https://archive.test/v1/archive')
        && $request['latitude'] == 37.98 && $request['longitude'] == 23.73
        && $request['start_date'] === '2016-01-01' && $request['end_date'] === '2016-01-02');
    Http::assertSent(fn (Request $request) => str_starts_with($request->url(), 'https://forecast.test/v1/forecast')
        && $request['forecast_days'] == 2);
    Http::assertNotSent(fn (Request $request) => str_contains($request->url(), '37.984'));
});

it('raises WeatherUnavailable on a timeout, an HTTP error or a malformed answer, without coordinates in the message', function (Closure $answer) {
    Http::fake(fn () => $answer());

    foreach (['elevation', 'history', 'forecast'] as $operation) {
        try {
            match ($operation) {
                'elevation' => (new OpenMeteoWeatherProvider)->elevation(37.98, 23.73),
                'history' => (new OpenMeteoWeatherProvider)->history(37.98, 23.73, CarbonImmutable::parse('2016-01-01'), CarbonImmutable::parse('2016-01-02')),
                'forecast' => (new OpenMeteoWeatherProvider)->forecast(37.98, 23.73, 2),
            };
            $this->fail("{$operation} did not fail");
        } catch (WeatherUnavailable $e) {
            expect($e->getMessage())->not->toContain('37.98')->not->toContain('23.73')
                ->and($e->getPrevious())->toBeNull();
        }
    }
})->with([
    'timeout' => fn () => fn () => throw new ConnectionException('cURL error 28: Operation timed out for https://forecast.test/?latitude=37.98&longitude=23.73'),
    'unavailable' => fn () => fn () => Http::response('down', 503),
    'malformed' => fn () => fn () => Http::response(['unexpected' => true]),
]);

it('binds the fake provider in tests and Open-Meteo when configured', function () {
    expect(app(WeatherProvider::class))->toBeInstanceOf(FakeWeatherProvider::class);

    config(['weather.provider' => 'open-meteo']);
    app()->forgetInstance(WeatherProvider::class);

    expect(app(WeatherProvider::class))->toBeInstanceOf(OpenMeteoWeatherProvider::class);
});

it('fake provider simulates failures per operation and records calls', function () {
    $fake = (new FakeWeatherProvider)->withElevation(640)->fail('timeout', ['history']);

    expect($fake->elevation(40.1, 21.9))->toBe(640)
        ->and(fn () => $fake->history(40.1, 21.9, CarbonImmutable::parse('2016-01-01'), CarbonImmutable::parse('2016-01-31')))
        ->toThrow(WeatherUnavailable::class, 'timed out');

    $fake->recover();

    expect($fake->history(40.1, 21.9, CarbonImmutable::parse('2016-01-01'), CarbonImmutable::parse('2016-01-31')))->toHaveCount(31)
        ->and($fake->callCount('history'))->toBe(2)
        ->and($fake->callCount('elevation'))->toBe(1);
});
