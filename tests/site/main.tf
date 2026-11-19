# Rendering of the stack's site template as the nginx module does it, for a run to read: the context
# reverse_proxy.tf passes, merged with the nginx module's own (the keys the template reads).

terraform {
  required_providers {
    jinja = {
      source = "NikolaLohinski/jinja"
    }
  }
}

variable "site" {
  type        = any
  description = "Context keys overriding the defaults below."
  default     = {}
}

locals {
  context = merge({
    name     = "app"
    inc_path = "${abspath("${path.module}/../../.terraform/modules/templates/inc")}/"
    host     = "app-web"
    port     = 8000
    domains  = ["app.example.com"]

    redirect_ssl = true
    with_dhparam = true
    with_http2   = true
    with_ssl     = true

    real_ip_from = "172.18.0.0/16"

    project_app = "app"

    media_directory     = "/data/media"
    protected_directory = "/data/protected"
    static_directory    = "/data/static"

    max_body_size = "20M"
    websocket     = null
    debug         = false

    admin_url = "admin"

    with_spa     = false
    django_paths = []

    error_log_level     = "warn"
    http_internal_port  = 80
    https_internal_port = 443
  }, var.site)
}

data "jinja_template" "site" {
  source {
    directory = path.module
    template  = file("${path.module}/../../sites/app.conf.j2")
  }
  context {
    type = "json"
    data = jsonencode(local.context)
  }
}

output "config" {
  description = "Rendered site configuration."
  value       = data.jinja_template.site.result
}
