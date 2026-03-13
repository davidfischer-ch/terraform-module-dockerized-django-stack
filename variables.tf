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
  default     = true
  description = "Toggle the containers (started or stopped)."
}

variable "wait" {
  type        = bool
  default     = true
  description = <<EOT
    Wait for the containers to reach an healthy state after creation.
    Current restriction: Applies only for Nginx, PostgreSQL and Redis.
  EOT
}

# Process ------------------------------------------------------------------------------------------

variable "app_image_name" {
  type        = string
  description = "Django application's image name"
}

variable "app_uid" {
  type        = number
  default     = 1001
  description = "UID of the user running the application container(s) and owning the data."
}

variable "app_gid" {
  type        = number
  default     = 1001
  description = "GID of the user running the application container(s) and owning the data."
}

# Networking ---------------------------------------------------------------------------------------

variable "hosts" {
  type        = map(string)
  default     = {}
  description = "Add entries to container hosts file."
}

variable "https_port" {
  type        = number
  description = "Bind the reverse proxy's HTTPS port."
}

variable "http_port" {
  type        = number
  description = "Bind the reverse proxy's HTTP port."
}

# Reverse Proxy ------------------------------------------------------------------------------------

variable "dhparam_use_dsa" {
  type        = bool
  default     = false
  description = <<EOT
    Use DSA (converted to DH) instead of "pure" DH params (DH by default).
    Much faster to generate but using "weaker" prime numbers.

    See https://docs.openssl.org/3.4/man1/openssl-dhparam/#options
  EOT
}

variable "ssl_crt" {
  type = string
}

variable "ssl_key" {
  type = string
}

variable "max_body_size" {
  type    = string
  default = "20M"
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
  default     = {}
  description = "Any additional environment variables for the application (e.g. { FOO = \"bar\" })"
}

variable "admin_name" {
  type = string
}

variable "admin_email" {
  type = string
}

variable "admin_url" {
  type    = string
  default = "admin"
}

variable "compress_enabled" {
  type    = bool
  default = false
}

variable "compress_offline" {
  type    = bool
  default = false
}

variable "csrf_trusted_origins" {
  type = list(string)
}

variable "debug" {
  type = bool
}

variable "debug_toolbar" {
  type = bool
}

variable "debug_toolbar_template_profiler" {
  type = bool
}

variable "default_from_email" {
  type = string
}

variable "domains" {
  type = list(string)
}

variable "email_backend" {
  type    = string
  default = "django.core.mail.backends.dummy.EmailBackend"
}

variable "email_file_path" {
  type    = string
  default = ""
}

variable "email_host" {
  type    = string
  default = ""
}

variable "email_host_password" {
  type      = string
  sensitive = true
  default   = ""
}

variable "email_host_user" {
  type    = string
  default = ""
}

variable "email_port" {
  type    = number
  default = 465
}

variable "email_subject_prefix" {
  type = string
}

variable "email_use_ssl" {
  type    = bool
  default = true
}

variable "email_use_tls" {
  type    = bool
  default = false
}

variable "managers" {
  type    = list(string)
  default = []
}

# Broker Container ---------------------------------------------------------------------------------

variable "redis_image_name" {
  type    = string
  default = "redis:latest"
}

variable "redis_uid" {
  type        = number
  default     = 999
  description = "UID of the user running the broker container and owning the data."
}

variable "redis_gid" {
  type        = number
  default     = 999
  description = "GID of the user running the broker container and owning the data."
}

# Database Container -------------------------------------------------------------------------------

variable "postgresql_image_name" {
  type    = string
  default = "postgres:latest"
}

variable "postgresql_uid" {
  type        = number
  default     = 999
  description = "UID of the user running the database container and owning the data directories."
}

variable "postgresql_gid" {
  type        = number
  default     = 0
  description = "GID of the user running the database container and owning the data directories."
}

variable "postgresql_max_connections" {
  type        = number
  default     = 100
  description = "Maximum number of PostgreSQL connections."
  validation {
    condition     = var.postgresql_max_connections >= 1 && var.postgresql_max_connections <= 262143
    error_message = "Argument `postgresql_max_connections` should be between 1 and 262143."
  }
}

# Reverse Proxy Container --------------------------------------------------------------------------

variable "nginx_image_name" {
  type    = string
  default = "nginx:latest"
}

variable "nginx_uid" {
  type        = number
  default     = 0
  description = <<EOT
    UID of the user running the reverse-proxy container.
    If not root then NET_IND_SERVICE capability will be added for nginx to bind ports 80/443.
  EOT
}

variable "nginx_gid" {
  type        = number
  default     = 0
  description = <<EOT
    GID of the user running the reverse-proxy container.
    If not root then NET_IND_SERVICE capability will be added for nginx to bind ports 80/443.
  EOT
}

variable "nginx_log_level" {
  type    = string
  default = "warn"
}

variable "nginx_modules" {
  type    = list(string)
  default = []
}

variable "with_spa" {
  type        = bool
  default     = false
  description = "Serve a bundled React SPA from Nginx (try_files fallback to index.html)."
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
