# Agrocult backend

Laravel 13 modular monolith (modules in `app/Modules/<Module>/`). Development runs in
Docker through Laravel Sail (`compose.yaml`): API, PostgreSQL 18, queue worker, scheduler.

## First run

```sh
cp .env.example .env
docker run --rm -u "$(id -u):$(id -g)" -v "$(pwd):/var/www/html" -w /var/www/html \
    laravelsail/php83-composer:latest composer install --ignore-platform-reqs
./vendor/bin/sail up -d
./vendor/bin/sail artisan key:generate
./vendor/bin/sail artisan migrate
```

Ports and the compose project name are read from `.env` (`APP_PORT`, `FORWARD_DB_PORT`,
`COMPOSE_PROJECT_NAME`). The containers always use PostgreSQL and log JSON to stderr.

## Checks (run inside Sail)

```sh
./vendor/bin/sail bin pint --test
./vendor/bin/sail bin phpstan analyse
./vendor/bin/sail bin deptrac analyse
./vendor/bin/sail bin pest
./vendor/bin/sail composer audit
```
