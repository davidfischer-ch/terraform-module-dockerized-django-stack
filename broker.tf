resource "docker_image" "redis" {
  name         = var.redis_image_name
  keep_locally = true # Prevent conflicts if other modules are using the image we are destroying
}

resource "random_password" "broker" {
  length  = 32
  special = false
}

module "broker" {
  source = "git::ssh://git@gitlab.fisch3r.net:10022/family/infrastructure/modules/terraform-module-dockerized-redis.git?ref=main"

  identifier     = "${var.identifier}-broker"
  enabled        = var.enabled
  image_id       = docker_image.redis.image_id
  data_directory = "${var.data_directory}/broker"

  network_id = docker_network.app.id

  databases = 2
  password  = random_password.broker.result
}
