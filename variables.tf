variable "identifier" {
  type = string
}

variable "enabled" {
  type = bool
}

variable "data_directory" {
  type = string
}

# Networking

variable "https_port" {
  type = number
}

variable "http_port" {
  type = number
}

# Reverse Proxy

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

# Django Application

variable "project_name" {
  type        = string
  description = "Django project's name (directory), for example DietApp."
}

variable "settings" {
  type        = map(string)
  default     = {}
  description = "Any additional environment variables for the application (e.g. { FOO = \"bar\" })"
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

# Images

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

# Web Container

variable "web" {
  type = object({
    concurrency   = optional(number, 1)
    log_level     = optional(string, "info")
    extra_options = optional(list(string), [])
  })

  validation {
    condition     = contains(["critical", "error", "warning", "info", "debug", "trace"], var.web.log_level)
    error_message = "Log level should be one of `critical`, `error`, `warning`, `info`, `debug`, `trace`"
  }
}

# Workers Containers

variable "beat" {
  type = object({
    log_level     = optional(string, "info")
    extra_options = optional(list(string), [])
  })

  validation {
    condition     = contains(["debug", "info", "warning", "error", "critical", "fatal"], var.beat.log_level)
    error_message = "Log level should be one of `debug`, `info`, `warning`, `error`, `critical`, `fatal`"
  }
}

variable "workers" {
  type = map(object({
    name          = string
    queues        = list(string)
    log_level     = optional(string, "info")
    extra_options = optional(list(string), [])
  }))
  description = "Celery workers settings. See `celery worker --help` for detailled description."

  validation {
    condition = alltrue([
      for w in var.workers :
      contains(["debug", "info", "warning", "error", "critical", "fatal"], w.log_level)
    ])
    error_message = "Log level should be one of `debug`, `info`, `warning`, `error`, `critical`, `fatal`"
  }
}
