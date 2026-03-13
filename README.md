# Django App Stack Terraform Module (Dockerized)

Manage a "standardized" Django application's stack.

* Runs all components on a dedicated bridge network
* Creates a web container (Uvicorn ASGI), a Celery beat scheduler, and Celery workers, via the `django-app` sub-module
* Provisions a PostgreSQL database, a Redis broker/cache, and an Nginx reverse proxy
* Supports sudoless local development by running all containers as the current host user

[TOC]

## Examples

### Server deployment (default)

See [examples/default](examples/default) for a complete working configuration.

Runs all containers as their default service-account users (e.g. `postgres:999`, `redis:999`) on
standard ports. Intended for server deployments where the host user is root or has the necessary
privileges to provision services and change files ownership.

```hcl
module "myapp" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-django-stack.git?ref=1.2.0"

  identifier     = "myapp"
  data_directory = "/data/myapp"

  # Networking

  https_port = 443
  http_port  = 80

  # Reverse Proxy

  ssl_crt = join("", [acme_certificate.myapp.certificate_pem, acme_certificate.myapp.issuer_pem])
  ssl_key = acme_certificate.myapp.private_key_pem

  # Django Application

  project_name         = "MyApp"
  project_app          = "myapp"
  site_name            = "My Application"
  admin_name           = "Admin User"
  admin_email          = "admin@example.com"
  csrf_trusted_origins = ["https://myapp.example.com"]
  default_from_email   = "noreply@example.com"
  domains              = ["myapp.example.com"]
  email_subject_prefix = "[My Application] "

  app_image_name        = "your-registry.io/myapp:latest"
  nginx_image_name      = "nginx:1.28.0"
  postgresql_image_name = "postgres:15.10"
  redis_image_name      = "redis:7.4.2"

  web    = { concurrency = 4, log_level = "info" }
  beat   = { log_level = "info" }
  workers = {
    default = { name = "default", queues = ["default"], log_level = "info" }
  }
}
```

### Local development (sudoless)

See [examples/current-user](examples/current-user) for a complete working configuration.

Runs all containers as the current host user via `data.external.current_user`, stores data under
`~/.apps/myapp`, and binds unprivileged ports (`8080`/`8443`) so no `sudo` is required.
Nginx automatically receives `NET_BIND_SERVICE` when `nginx_uid` is non-zero.

```hcl
data "external" "current_user" {
  program = ["sh", "-c", "printf '{\"uid\":\"%s\",\"gid\":\"%s\"}' \"$(id -u)\" \"$(id -g)\""]
}

module "myapp" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-django-stack.git?ref=1.2.0"

  identifier     = "myapp"
  data_directory = pathexpand("~/.apps/myapp")

  # Networking

  https_port = 8443
  http_port  = 8080

  # ...

  # Process — run all containers as the current host user

  app_uid        = tonumber(data.external.current_user.result.uid)
  app_gid        = tonumber(data.external.current_user.result.gid)
  redis_uid      = tonumber(data.external.current_user.result.uid)
  redis_gid      = tonumber(data.external.current_user.result.gid)
  postgresql_uid = tonumber(data.external.current_user.result.uid)
  postgresql_gid = tonumber(data.external.current_user.result.gid)
  nginx_uid      = tonumber(data.external.current_user.result.uid)
  nginx_gid      = tonumber(data.external.current_user.result.gid)

  # ...
}
```

## Data layout

All persistent data lives under `data_directory`:

```
data_directory/
├── app/
│   ├── config/     # Generated settings.env
│   ├── media/      # User-uploaded media files
│   ├── protected/  # Protected files (served via X-Accel-Redirect)
│   ├── static/     # Collected static files
│   └── workers/    # Celery beat and worker state databases
├── broker/         # Redis data
├── database/       # PostgreSQL data
└── reverse-proxy/  # Nginx configuration, certificates, dhparam
```

## Passwords

The Redis broker and PostgreSQL database passwords are **generated automatically** by Terraform
(`random_password`) and stored in the state file. They are never exposed as output variables.

To rotate a password, taint the corresponding resource and re-apply:

```
terraform taint 'module.myapp.random_password.broker'
terraform taint 'module.myapp.random_password.database'
terraform apply
```

## Variables

| Name | Type | Default | Description |
|------|------|---------|-------------|
| `identifier` | `string` | — | Unique name for resources (must match `^[a-z]+(-[a-z0-9]+)*$`). |
| `enabled` | `bool` | `true` | Start or stop the containers. |
| `wait` | `bool` | `true` | Wait for containers to reach a healthy state after creation (applies to Nginx, PostgreSQL, Redis). |
| `app_image_name` | `string` | — | Django application Docker image name. |
| `app_uid` | `number` | `1001` | UID of the user running the application containers and owning the data. |
| `app_gid` | `number` | `1001` | GID of the user running the application containers and owning the data. |
| `hosts` | `map(string)` | `{}` | Extra `/etc/hosts` entries for the containers. |
| `https_port` | `number` | — | Bind the reverse proxy's HTTPS port. |
| `http_port` | `number` | — | Bind the reverse proxy's HTTP port. |
| `dhparam_use_dsa` | `bool` | `false` | Use DSA instead of DH params (faster to generate but weaker). |
| `ssl_crt` | `string` | — | SSL certificate (PEM). |
| `ssl_key` | `string` | — | SSL private key (PEM, sensitive). |
| `max_body_size` | `string` | `"20M"` | Nginx client max body size. |
| `data_directory` | `string` | — | Host path for persistent volumes. |
| `project_name` | `string` | — | Django project directory name (e.g. `MyApp`). |
| `project_app` | `string` | — | Django project's main application name (e.g. `myapp`). |
| `site_name` | `string` | — | Django site display name. |
| `settings` | `map(string)` | `{}` | Additional environment variables for the application. |
| `admin_name` | `string` | — | Admin display name. |
| `admin_email` | `string` | — | Admin email address. |
| `admin_url` | `string` | `"admin"` | Admin URL prefix. |
| `compress_enabled` | `bool` | `false` | Enable Django Compressor. |
| `compress_offline` | `bool` | `false` | Enable offline compression. |
| `csrf_trusted_origins` | `list(string)` | — | CSRF trusted origins. |
| `debug` | `bool` | — | Enable Django debug mode. |
| `debug_toolbar` | `bool` | — | Enable Django Debug Toolbar. |
| `debug_toolbar_template_profiler` | `bool` | — | Enable Debug Toolbar template profiler. |
| `default_from_email` | `string` | — | Default sender email address. |
| `domains` | `list(string)` | — | Allowed domains (`ALLOWED_HOSTS`). |
| `email_backend` | `string` | `"django.core.mail.backends.dummy.EmailBackend"` | Email backend class. |
| `email_file_path` | `string` | `""` | File path for file-based email backend. |
| `email_host` | `string` | `""` | SMTP host. |
| `email_host_password` | `string` | `""` | SMTP password (sensitive). |
| `email_host_user` | `string` | `""` | SMTP username. |
| `email_port` | `number` | `465` | SMTP port. |
| `email_subject_prefix` | `string` | — | Email subject prefix. |
| `email_use_ssl` | `bool` | `true` | Use SSL for SMTP. |
| `email_use_tls` | `bool` | `false` | Use TLS for SMTP. |
| `managers` | `list(string)` | `[]` | Django `MANAGERS` setting. |
| `redis_image_name` | `string` | `"redis:latest"` | [Redis](https://hub.docker.com/_/redis/tags) Docker image name. |
| `redis_uid` | `number` | `999` | UID of the user running the broker container and owning the data. |
| `redis_gid` | `number` | `999` | GID of the user running the broker container and owning the data. |
| `postgresql_image_name` | `string` | `"postgres:latest"` | [PostgreSQL](https://hub.docker.com/_/postgres/tags) Docker image name. |
| `postgresql_uid` | `number` | `999` | UID of the user running the database container and owning the data. |
| `postgresql_gid` | `number` | `0` | GID of the user running the database container and owning the data. |
| `postgresql_max_connections` | `number` | `100` | PostgreSQL max connections. |
| `nginx_image_name` | `string` | `"nginx:latest"` | [Nginx](https://hub.docker.com/_/nginx/tags) Docker image name. |
| `nginx_uid` | `number` | `0` | UID of the user running the reverse-proxy container. Non-zero automatically adds `NET_BIND_SERVICE`. |
| `nginx_gid` | `number` | `0` | GID of the user running the reverse-proxy container. |
| `nginx_log_level` | `string` | `"warn"` | Nginx error log level. |
| `nginx_modules` | `list(string)` | `[]` | Extra Nginx modules to load. |
| `with_spa` | `bool` | `false` | Serve a bundled React SPA from Nginx (`try_files` fallback to `index.html`). |
| `web` | `object` | — | Web container settings (`concurrency`, `log_level`). |
| `beat` | `object` | — | Celery beat settings (`log_level`, `extra_options`). |
| `workers` | `map(object)` | — | Celery workers settings (`name`, `queues`, `log_level`, `extra_options`). |

## Requirements

* Terraform >= 1.6
* [kreuzwerker/docker](https://github.com/kreuzwerker/terraform-provider-docker) >= 3.0.2
* [hashicorp/local](https://github.com/hashicorp/terraform-provider-local) >= 2.4.1
* [hashicorp/random](https://github.com/hashicorp/terraform-provider-random) >= 3.6.0

## Actions

Examples are based on the following configuration (application called `myapp`):

### Generate static files

```
sudo docker exec -it myapp-web python manage.py collectstatic
```

Files will be generated under `/data/myapp/app/static/` directory.

### Migrate database

```
sudo docker exec -it myapp-web python manage.py migrate
```

### Backup and restore database

See [PostgreSQL Terraform Module (Dockerized)](https://github.com/davidfischer-ch/terraform-module-dockerized-postgresql).

### Backup media assets

```
BACKUP_PATH=/my/backup/myapp-dev/
rsync -ah -lH --delete --progress /data/myapp-dev/app/media/ "$BACKUP_PATH/media/"
rsync -ah -lH --delete --progress /data/myapp-dev/app/protected/ "$BACKUP_PATH/protected/"
```

### Restore media assets

```
BACKUP_PATH=/my/backup/myapp-dev/
rsync -ah -lH --delete --progress "$BACKUP_PATH/media/" /data/myapp-dev/app/media/
rsync -ah -lH --delete --progress "$BACKUP_PATH/protected/" /data/myapp-dev/app/protected/
```
