resource "docker_image" "app" {
  name         = var.app_image_name
  keep_locally = true # Prevent conflicts if other modules are using the image we are destroying
}

module "app" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-django-app.git?ref=1.0.1"

  identifier     = var.identifier
  enabled        = var.enabled
  image_id       = docker_image.app.image_id
  data_directory = "${var.data_directory}/app"
  data_owner     = var.data_owner

  # Networking

  hosts      = var.hosts
  network_id = docker_network.app.id

  # Django Application

  project_name = var.project_name
  site_name    = var.site_name
  settings     = var.settings

  admin_name  = var.admin_name
  admin_email = var.admin_email
  admin_url   = var.admin_url

  compress_enabled = var.compress_enabled
  compress_offline = var.compress_offline

  csrf_trusted_origins = var.csrf_trusted_origins

  debug                           = var.debug
  debug_toolbar                   = var.debug_toolbar
  debug_toolbar_template_profiler = var.debug_toolbar_template_profiler

  default_from_email = var.default_from_email

  domains = var.domains

  email_backend        = var.email_backend
  email_file_path      = var.email_file_path
  email_host           = var.email_host
  email_host_password  = var.email_host_password
  email_host_user      = var.email_host_user
  email_port           = var.email_port
  email_subject_prefix = var.email_subject_prefix
  email_use_ssl        = var.email_use_ssl
  email_use_tls        = var.email_use_tls

  managers = var.managers

  broker_host     = module.broker.host
  broker_port     = module.broker.port
  broker_index    = 1
  broker_password = module.broker.password

  cache_host     = module.broker.host
  cache_port     = module.broker.port
  cache_index    = 0
  cache_password = module.broker.password

  database_host     = module.database.host
  database_port     = module.database.port
  database_name     = module.database.name
  database_user     = module.database.user
  database_password = module.database.password

  web     = var.web
  beat    = var.beat
  workers = var.workers
}
