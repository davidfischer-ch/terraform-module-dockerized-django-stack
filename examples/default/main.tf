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

module "myapp" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-django-stack.git?ref=1.0.4"

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
