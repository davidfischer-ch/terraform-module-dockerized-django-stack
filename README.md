# Django App Stack Terraform Module (Dockerized)

Manage a "standardized" Django application's stack.

[TOC]

## Example

See [examples/default](examples/default) for a complete working configuration.

Example for an application called `myapp` :

```hcl
provider "acme" {
  server_url = "https://acme-v02.api.letsencrypt.org/directory"
}

resource "aws_route53_zone" "main" {
  name = "example.com"
}

resource "acme_registration" "main" {
  email_address = "admin@example.com"
}

resource "acme_certificate" "myapp" {
  account_key_pem = acme_registration.main.account_key_pem
  common_name     = "myapp.example.com"

  dns_challenge {
    provider = "route53"

    config = {
      AWS_HOSTED_ZONE_ID = aws_route53_zone.main.zone_id
    }
  }
}

module "myapp_dev" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-django-stack.git?ref=1.0.4"

  identifier     = "myapp-dev"
  enabled        = true
  data_directory = "/data/myapp-dev"

  # Networking

  https_port = 10443
  http_port  = 10080

  # Reverse Proxy

  ssl_crt       = join("", [acme_certificate.myapp.certificate_pem, acme_certificate.myapp.issuer_pem])
  ssl_key       = acme_certificate.myapp.private_key_pem
  max_body_size = "20M"

  # Django Application

  project_name                    = "MyApp"
  project_app                     = "myapp"
  site_name                       = "My Application"
  settings                        = {}
  admin_name                      = "Admin User"
  admin_email                     = "admin@example.com"
  admin_url                       = "A2br2wZDmTHlCjQq"
  compress_enabled                = false
  compress_offline                = false
  csrf_trusted_origins            = ["https://myapp.example.com"]
  debug                           = true
  debug_toolbar                   = true
  debug_toolbar_template_profiler = true
  default_from_email              = "admin@example.com"
  domains                         = ["myapp.example.com"]
  email_backend                   = "django.core.mail.backends.dummy.EmailBackend"
  email_subject_prefix            = "[My Application | DEV] "
  managers                        = []

  app_image_name = "your-registry.io/myapp:3.0.2-1"

  nginx_image_name      = "nginx:1.28.0"   # https://hub.docker.com/_/nginx/tags
  postgresql_image_name = "postgres:15.10" # https://hub.docker.com/_/postgres/tags
  redis_image_name      = "redis:7.4.2"    # https://hub.docker.com/_/redis/tags

  web = {
    concurrency = 4
    log_level   = "info"
  }

  beat = {
    log_level = "info"
  }

  workers = {
    default = {
      name      = "default"
      queues    = ["default"]
      log_level = "info"
    }
  }
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
