resource "docker_image" "postgresql" {
  name         = var.postgresql_image_name
  keep_locally = true # Prevent conflicts if other modules are using the image we are destroying
}

resource "random_password" "database" {
  length  = 32
  special = false
}

module "database" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-postgresql.git?ref=1.2.1"

  identifier = "${var.identifier}-database"
  enabled    = var.enabled
  wait       = var.wait

  image_id = docker_image.postgresql.image_id
  app_uid  = var.postgresql_uid
  app_gid  = var.postgresql_gid

  hosts      = var.hosts
  network_id = docker_network.app.id

  data_directory = "${var.data_directory}/database"

  name     = var.identifier
  user     = var.identifier
  password = random_password.database.result

  max_connections = var.postgresql_max_connections
}
