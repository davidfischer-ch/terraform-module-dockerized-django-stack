# Changelog

## Release v1.2.0 (2026-03-13)

### Minor compatibility breaks

* Change `extra_volumes` type from `list(object)` to `map(object)` — existing list usages must be converted to a map with named keys

### Fix and enhancements

* Upgrade `django-app` module to 1.1.1
* Upgrade `nginx` module to 1.1.3
* Upgrade `postgresql` module to 1.2.2
* Upgrade `redis` module to 1.1.1
* Set `enabled` and `wait` defaults to `true`
* Refine variable descriptions, validators, and attribute ordering
* Remove redundant default values from examples and README

## Release v1.1.2 (2026-03-13)

### Fix and enhancements

* Upgrade `nginx` module to 1.1.2

## Release v1.1.1 (2026-03-13)

### Features

* Add variable `wait` (default to `false`)

### Fix and enhancements

* Upgrade `postgresql` module version to 1.2.1
* Reorder variables to be consistent

## Release v1.1.0 (2026-03-13)

### Minor compatibility breaks

* Replace `data_owner` by `app_uid`, `app_gid` with the same default values of `1001`

### Features

* Add `app_uid`/`app_gid` process identity variables for the Django app & workers (default `1001`)
* Add `nginx_uid`/`nginx_gid` process identity variables for the reverse proxy (default `0`)
* Add `postgresql_uid`/`postgresql_gid` process identity variables for the database (default `999`/`0`)
* Add `redis_uid`/`redis_gid` process identity variables for the broker (default `999`)
* Automatically adds `NET_BIND_SERVICE` capability to nginx container if `uid` is not root (required for ports binding)

### Fix and enhancements

* Upgrade `django-app` module version to 1.1.0
* Upgrade `nginx` module version to 1.1.1
* Upgrade `postgresql` module version to 1.2.0
* Upgrade `redis` module version to 1.1.0
* Add `examples/default/` (server deployment) and `examples/current-user/` (local dev as current user)
* Update README accordingly

## Release v1.0.4 (2026-02-24)

### Features

* Add `with_spa` option

## Release v1.0.3 (2025-08-23)

### Fix and enhancements

* Upgrade `django-app` module version to 1.0.1
* Upgrade `postgresql` module version to 1.0.1
* Upgrade `redis` module version to 1.0.1

## Release v1.0.2 (2025-06-11)

### Features

* Add variable `dhparam_use_dsa` (default to `false`)

### Fix and enhancements

* Upgrade `nginx` module version 1.0.2

## Release v1.0.1 (2025-06-11)

### Fix and enhancements

* Update modules URLs

## Release v1.0.0 (2025-01-20)

Initial release
