# Django App Stack Terraform Module (Dockerized)

Manage a "standardized" Django application's stack.

[TOC]

## Examples

### Server deployment (default)

See [examples/default](examples/default) for a complete working configuration.

Runs all containers as their default service-account users (e.g. `postgres:999`, `redis:999`) on
standard ports. Intended for server deployments where the host user is root or has the necessary
privileges to provision services and change files ownership.

```hcl
module "myapp" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-django-stack.git?ref=1.1.0"

  identifier     = "myapp"
  enabled        = true
  data_directory = "/data/myapp"

  # Networking

  https_port = 443
  http_port  = 80

  # Reverse Proxy

  ssl_crt       = join("", [acme_certificate.myapp.certificate_pem, acme_certificate.myapp.issuer_pem])
  ssl_key       = acme_certificate.myapp.private_key_pem
  max_body_size = "20M"

  # Django Application

  project_name                    = "MyApp"
  project_app                     = "myapp"
  site_name                       = "My Application"
  admin_name                      = "Admin User"
  admin_email                     = "admin@example.com"
  csrf_trusted_origins            = ["https://myapp.example.com"]
  debug                           = false
  debug_toolbar                   = false
  debug_toolbar_template_profiler = false
  default_from_email              = "noreply@example.com"
  domains                         = ["myapp.example.com"]
  email_subject_prefix            = "[My Application] "

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
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-django-stack.git?ref=1.1.0"

  identifier     = "myapp"
  enabled        = true
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

## Actions

Examples are based on the following configuration (application called `myapp`) :

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
