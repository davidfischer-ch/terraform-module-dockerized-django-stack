resource "docker_image" "redis" {
  name         = var.redis_image_name
  keep_locally = true # Prevent conflicts if other modules are using the image we are destroying
}

resource "random_password" "broker" {
  length  = 32
  special = false
}

module "broker" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-redis.git?ref=1.2.1"

  identifier = "${var.identifier}-broker"
  enabled    = var.enabled
  wait       = var.wait
  image_id   = docker_image.redis.image_id

  # Process

  app_uid = var.redis_uid
  app_gid = var.redis_gid

  # Networking

  hosts      = var.hosts
  network_id = docker_network.app.id

  # Storage

  data_directory = "${var.data_directory}/broker"

  # Configuration

  databases = 2

  # Authentication

  password = random_password.broker.result
}
