# Django App Stack Terraform Module (Dockerized)

Manage a "standardized" Django application's stack.

## Example

Example for an application called `diet` :

```
module "diet_dev" {
  source = "git::ssh://git@gitlab.fisch3r.net:10022/family/infrastructure/modules/terraform-module-dockerized-django-stack.git?ref=main"

  identifier     = "diet-dev"
  enabled        = true
  data_directory = "/data/diet-dev"

  # Networking

  https_port = 10443
  http_port  = 10080

  # Reverse Proxy

  ssl_crt       = module.fisch3r_net.crt
  ssl_key       = module.fisch3r_net.key
  max_body_size = "20M"

  # Django Application

  project_name                    = "DietApp"
  project_app                     = "diet"
  site_name                       = "Diet Application"
  settings                        = {}
  admin_name                      = "David Fischer"
  admin_email                     = "david@fisch3r.net"
  admin_url                       = "A2br2wZDmTHlCjQq"
  compress_enabled                = false
  compress_offline                = false
  csrf_trusted_origins            = ["https://diet-dev.fisch3r.net"]
  debug                           = true
  debug_toolbar                   = true
  debug_toolbar_template_profiler = true
  default_from_email              = "david@fisch3r.net"
  domains                         = ["diet-dev.fisch3r.net"]
  email_backend                   = "django.core.mail.backends.dummy.EmailBackend"
  email_subject_prefix            = "[Diet Application | DEV] "
  managers                        = []

  app_image_name = "your-registry.io/diet:3.0.2-1"

  nginx_image_name      = "nginx:1.25.1"  # https://hub.docker.com/_/nginx/tags
  postgresql_image_name = "postgres:15.3" # https://hub.docker.com/_/postgres/tags
  redis_image_name      = "redis:7.0.11"  # https://hub.docker.com/_/redis/tags

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

Examples are based on the following configuration (application called `diet`) :

### Generate static files

```
sudo docker exec -it diet-web python manage.py collectstatic
```

Files will be generated under `/data/diet/app/static/` directory.

### Migrate database

```
sudo docker exec -it diet-web python manage.py migrate
```

### Restore DB from a dump

```
sudo docker cp db.sql diet-database:/var/lib/postgresql/data/db.sql
sudo docker exec -it diet-database /bin/bash
root@diet-database:# psql -U diet -d diet < /var/lib/postgresql/data/db.sql
```
