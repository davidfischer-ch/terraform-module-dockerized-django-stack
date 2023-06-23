resource "docker_image" "postgresql" {
  name = var.postgresql_image_name
}

resource "random_password" "database" {
  length  = 32
  special = false
}

module "database" {
  source = "git::ssh://git@gitlab.fisch3r.net:10022/family/infrastructure/modules/terraform-module-dockerized-postgresql.git?ref=main"

  identifier     = "${var.identifier}-database"
  enabled        = var.enabled
  image_id       = docker_image.postgresql.image_id
  data_directory = "${var.data_directory}/database"

  network_id = docker_network.app.id

  name     = var.identifier
  user     = var.identifier
  password = random_password.database.result

  max_connections = var.postgresql_max_connections
}
