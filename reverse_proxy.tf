resource "docker_image" "nginx" {
  name         = var.nginx_image_name
  keep_locally = true # Prevent conflicts if other modules are using the image we are destroying
}

module "reverse_proxy" {
  source = "git::ssh://git@gitlab.fisch3r.net:10022/family/infrastructure/modules/terraform-module-dockerized-nginx.git?ref=main"

  identifier     = "${var.identifier}-reverse-proxy"
  enabled        = var.enabled
  image_id       = docker_image.nginx.image_id
  data_directory = "${var.data_directory}/reverse-proxy"

  # Logging

  error_log_level = var.nginx_log_level

  # Miscellaneous

  modules = var.nginx_modules

  # Networking

  hosts      = var.hosts
  network_id = docker_network.app.id
  https_port = var.https_port
  http_port  = var.http_port

  # Volumes

  extra_volumes = [
    {
      container_path = "/data/media"
      host_path      = module.app.media_directory
      read_only      = true
    },
    {
      container_path = "/data/protected"
      host_path      = module.app.protected_directory
      read_only      = true
    },
    {
      container_path = "/data/static"
      host_path      = module.app.static_directory
      read_only      = true
    }
  ]

  # Sites

  sites = {
    app = {
      name     = var.identifier
      path     = "${path.module}/sites/app.conf.j2"
      inc_path = module.templates.inc_path
      host     = module.app.host
      port     = module.app.port
      domains  = var.domains

      redirect_ssl = true
      with_dhparam = true
      with_http2   = true
      with_ssl     = true
      ssl_crt      = var.ssl_crt
      ssl_key      = var.ssl_key

      project_app = var.project_app

      media_directory     = "/data/media"
      protected_directory = "/data/protected"
      static_directory    = "/data/static"

      max_body_size = var.max_body_size
      debug         = var.debug
    }
  }
}
