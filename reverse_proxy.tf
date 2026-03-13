resource "docker_image" "nginx" {
  name         = var.nginx_image_name
  keep_locally = true # Prevent conflicts if other modules are using the image we are destroying
}

module "reverse_proxy" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-nginx.git?ref=1.2.0"

  identifier = "${var.identifier}-reverse-proxy"
  enabled    = var.enabled
  wait       = var.wait

  image_id = docker_image.nginx.image_id
  app_uid  = var.nginx_uid
  app_gid  = var.nginx_gid
  cap_add  = var.nginx_uid == 0 ? [] : ["NET_BIND_SERVICE"]

  data_directory = "${var.data_directory}/reverse-proxy"

  # Logging

  error_log_level = var.nginx_log_level

  # Miscellaneous

  modules = var.nginx_modules

  # Networking

  hosts      = var.hosts
  https_port = var.https_port
  http_port  = var.http_port
  network_id = docker_network.app.id

  # Security

  dhparam_use_dsa = var.dhparam_use_dsa

  # Volumes

  extra_volumes = {
    media = {
      container_path = "/data/media"
      host_path      = module.app.media_directory
      read_only      = true
    }
    protected = {
      container_path = "/data/protected"
      host_path      = module.app.protected_directory
      read_only      = true
    }
    static = {
      container_path = "/data/static"
      host_path      = module.app.static_directory
      read_only      = true
    }
  }

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
      with_spa      = var.with_spa
    }
  }
}
