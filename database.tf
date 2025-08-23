resource "docker_image" "postgresql" {
  name         = var.postgresql_image_name
  keep_locally = true # Prevent conflicts if other modules are using the image we are destroying
}

resource "random_password" "database" {
  length  = 32
  special = false
}

module "database" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-postgresql.git?ref=1.0.1"

  identifier     = "${var.identifier}-database"
  enabled        = var.enabled
  image_id       = docker_image.postgresql.image_id
  data_directory = "${var.data_directory}/database"

  hosts      = var.hosts
  network_id = docker_network.app.id

  name     = var.identifier
  user     = var.identifier
  password = random_password.database.result

  max_connections = var.postgresql_max_connections
}
