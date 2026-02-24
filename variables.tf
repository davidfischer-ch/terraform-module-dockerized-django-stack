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
}

# Storage ------------------------------------------------------------------------------------------

variable "data_directory" {
  type        = string
  description = "Where data will be persisted (volumes will be mounted as sub-directories)."
}

variable "data_owner" {
  type        = string
  default     = "1001:1001"
  description = "Used to set the ownership of application's data directories."
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

# Images -------------------------------------------------------------------------------------------

variable "app_image_name" {
  type        = string
  description = "Django application's image name"
}

variable "nginx_image_name" {
  type    = string
  default = "nginx:latest"
}

variable "postgresql_image_name" {
  type    = string
  default = "postgres:latest"
}

variable "redis_image_name" {
  type    = string
  default = "redis:latest"
}

# Database Container -------------------------------------------------------------------------------

variable "postgresql_max_connections" {
  type    = number
  default = 100
}

# Reverse Proxy Container --------------------------------------------------------------------------

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
