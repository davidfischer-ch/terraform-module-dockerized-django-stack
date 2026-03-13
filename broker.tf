resource "docker_image" "redis" {
  name         = var.redis_image_name
  keep_locally = true # Prevent conflicts if other modules are using the image we are destroying
}

resource "random_password" "broker" {
  length  = 32
  special = false
}

module "broker" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-redis.git?ref=1.1.1"

  identifier = "${var.identifier}-broker"
  enabled    = var.enabled
  wait       = var.wait

  image_id = docker_image.redis.image_id
  app_uid  = var.redis_uid
  app_gid  = var.redis_gid

  data_directory = "${var.data_directory}/broker"

  hosts      = var.hosts
  network_id = docker_network.app.id

  databases = 2
  password  = random_password.broker.result
}
