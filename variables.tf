variable "identifier" {
  type        = string
  description = "Identifier (must be unique, used to name resources)."

  validation {
    condition     = regex("^[a-z]+(-[a-z0-9]+)*$", var.identifier) != null
    error_message = "Argument `identifier` must match regex ^[a-z]+(-[a-z0-9]+)*$."
  }
}

variable "enabled" {
  type        = bool
  description = "Toggle the containers (started or stopped)."
  default     = true
}

variable "wait" {
  type        = bool
  description = <<EOT
    Wait for the containers to reach an healthy state after creation.
    Current restriction: Applies only for Nginx, PostgreSQL and Redis.
  EOT
  default     = true
}

# Process ------------------------------------------------------------------------------------------

variable "app_image_name" {
  type        = string
  description = "Django application's image name"
}

variable "app_uid" {
  type        = number
  description = "UID of the user running the application container(s) and owning the data."
  default     = 1001
}

variable "app_gid" {
  type        = number
  description = "GID of the user running the application container(s) and owning the data."
  default     = 1001
}

# Networking ---------------------------------------------------------------------------------------

variable "hosts" {
  type        = map(string)
  description = "Add entries to container hosts file."
  default     = {}
}

variable "https_port" {
  type        = number
  description = "Bind the reverse proxy's HTTPS port."

  validation {
    condition     = var.https_port >= 1 && var.https_port <= 65535
    error_message = "Argument `https_port` must be between 1 and 65535."
  }
}

variable "http_port" {
  type        = number
  description = "Bind the reverse proxy's HTTP port."

  validation {
    condition     = var.http_port >= 1 && var.http_port <= 65535
    error_message = "Argument `http_port` must be between 1 and 65535."
  }
}

# Reverse Proxy ------------------------------------------------------------------------------------

variable "dhparam_use_dsa" {
  type        = bool
  description = <<EOT
    Use DSA (converted to DH) instead of "pure" DH params (DH by default).
    Much faster to generate but using "weaker" prime numbers.

    See https://docs.openssl.org/3.4/man1/openssl-dhparam/#options
  EOT
  default     = false
}

variable "ssl_crt" {
  type        = string
  description = "TLS certificate content (PEM format)."
}

variable "ssl_key" {
  type        = string
  description = "TLS private key content (PEM format)."
  sensitive   = true
}

variable "max_body_size" {
  type        = string
  description = "Maximum allowed size of the client request body (default: \"20M\")."
  default     = "20M"
}

# Storage ------------------------------------------------------------------------------------------

variable "data_directory" {
  type        = string
  description = "Where data will be persisted (volumes will be mounted as sub-directories)."
}

# Django Application -------------------------------------------------------------------------------

variable "project_name" {
  type        = string
  description = "Django project's name (directory), for example DietApp."
}

variable "project_app" {
  type        = string
  description = "Django project's main application (containing robots.txt and favicons in static)."
}

variable "site_name" {
  type        = string
  description = "Django site's name, for example \"Diet Application\"."
}

variable "settings" {
  type        = map(string)
  description = "Any additional environment variables for the application (e.g. { FOO = \"bar\" })"
  default     = {}
}

variable "admin_name" {
  type        = string
  description = "Django admin full name."
}

variable "admin_email" {
  type        = string
  description = "Django admin email address."

  validation {
    condition     = can(regex("^[^@]+@[^@]+$", var.admin_email))
    error_message = "Argument `admin_email` must be a valid email address."
  }
}

variable "admin_url" {
  type        = string
  description = "URL path for the Django admin interface."
  default     = "admin"

  validation {
    condition     = length(var.admin_url) > 0
    error_message = "Argument `admin_url` must not be empty."
  }
}

variable "csrf_trusted_origins" {
  type        = list(string)
  description = "List of trusted origins for CSRF protection."
}

variable "debug" {
  type        = bool
  description = "Enable Django debug mode."
  default     = false
}

variable "debug_toolbar" {
  type        = bool
  description = "Enable Django Debug Toolbar."
  default     = false
}

variable "default_from_email" {
  type        = string
  description = "Default sender address for outgoing emails."

  validation {
    condition     = can(regex("^[^@]+@[^@]+$", var.default_from_email))
    error_message = "Argument `default_from_email` must be a valid email address."
  }
}

variable "domains" {
  type        = list(string)
  description = "Allowed domains for the application (used in nginx server_name)."
}

variable "email_backend" {
  type        = string
  description = "Django email backend class."
  default     = "django.core.mail.backends.dummy.EmailBackend"
}

variable "email_file_path" {
  type        = string
  description = "File path for the file-based email backend."
  default     = ""
}

variable "email_host" {
  type        = string
  description = "SMTP server hostname."
  default     = ""
}

variable "email_host_password" {
  type        = string
  description = "SMTP server password."
  default     = ""
  sensitive   = true
}

variable "email_host_user" {
  type        = string
  description = "SMTP server username."
  default     = ""
}

variable "email_port" {
  type        = number
  description = "SMTP server port."
  default     = 465

  validation {
    condition     = var.email_port >= 1 && var.email_port <= 65535
    error_message = "Argument `email_port` must be between 1 and 65535."
  }
}

variable "email_subject_prefix" {
  type        = string
  description = "Prefix prepended to the subject of emails sent to admins and managers."
}

variable "email_use_ssl" {
  type        = bool
  description = "Use implicit TLS (SMTPS) when connecting to the SMTP server."
  default     = true
}

variable "email_use_tls" {
  type        = bool
  description = "Use explicit TLS (STARTTLS) when connecting to the SMTP server."
  default     = false
}

variable "managers" {
  type        = list(string)
  description = "List of manager email addresses to receive broken link notifications."
  default     = []

  validation {
    condition     = alltrue([for m in var.managers : can(regex("^[^@]+@[^@]+$", m))])
    error_message = "Each entry in `managers` must be a valid email address."
  }
}

# Broker Container ---------------------------------------------------------------------------------

variable "redis_image_name" {
  type        = string
  description = "Redis image name."
  default     = "redis:latest"
}

variable "redis_uid" {
  type        = number
  description = "UID of the user running the broker container and owning the data."
  default     = 999
}

variable "redis_gid" {
  type        = number
  description = "GID of the user running the broker container and owning the data."
  default     = 999
}

# Database Container -------------------------------------------------------------------------------

variable "postgresql_image_name" {
  type        = string
  description = "PostgreSQL image name."
  default     = "postgres:latest"
}

variable "postgresql_uid" {
  type        = number
  description = "UID of the user running the database container and owning the data directories."
  default     = 999
}

variable "postgresql_gid" {
  type        = number
  description = "GID of the user running the database container and owning the data directories."
  default     = 0
}

variable "postgresql_max_connections" {
  type        = number
  description = "Maximum number of PostgreSQL connections."
  default     = 100

  validation {
    condition     = var.postgresql_max_connections >= 1 && var.postgresql_max_connections <= 262143
    error_message = "Argument `postgresql_max_connections` should be between 1 and 262143."
  }
}

# Reverse Proxy Container --------------------------------------------------------------------------

variable "nginx_image_name" {
  type        = string
  description = "Nginx image name."
  default     = "nginx:latest"
}

variable "nginx_uid" {
  type        = number
  description = <<EOT
    UID of the user running the reverse-proxy container.
    If not root then NET_IND_SERVICE capability will be added for nginx to bind ports 80/443.
  EOT
  default     = 0
}

variable "nginx_gid" {
  type        = number
  description = <<EOT
    GID of the user running the reverse-proxy container.
    If not root then NET_IND_SERVICE capability will be added for nginx to bind ports 80/443.
  EOT
  default     = 0
}

variable "nginx_log_level" {
  type        = string
  description = "Nginx error log level."
  default     = "warn"
}

variable "nginx_modules" {
  type        = list(string)
  description = "Nginx modules to enable."
  default     = []
}

variable "app_conf_template" {
  type        = string
  description = <<EOT
    Path to a custom Jinja2 nginx site template.
    Defaults to the built-in sites/app.conf.j2."
  EOT
  default     = null
}

variable "with_spa" {
  type        = bool
  description = "Serve a bundled React SPA from Nginx (try_files fallback to index.html)."
  default     = false
}

variable "django_paths" {
  type        = list(string)
  description = <<EOT
    Additional path prefixes to proxy to the Django backend. Only used when `with_spa = true`.
    `/api` and `admin_url` are always proxied automatically and must not be listed here.
    Typical values: "i18n" (JavaScriptCatalog), "avatar", "en", "fr" (i18n_patterns language prefixes).
    Pure SPA projects with no Django-template views can pass an empty list.
  EOT
  default     = null

  validation {
    condition     = !var.with_spa || var.django_paths != null
    error_message = "django_paths must be set explicitly when with_spa = true (use [] for a pure SPA with no extra Django paths)."
  }
}

# Web Container ------------------------------------------------------------------------------------

variable "web" {
  description = "Application's settings."
}

# Workers Containers -------------------------------------------------------------------------------

variable "beat" {
  description = "Celery beat settings."
}

variable "workers" {
  description = "Celery workers settings. See `celery worker --help` for detailled description."
}
