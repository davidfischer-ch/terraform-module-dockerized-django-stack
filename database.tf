resource "docker_image" "postgresql" {
  name         = var.postgresql_image_name
  keep_locally = true # Prevent conflicts if other modules are using the image we are destroying
}

resource "random_password" "database" {
  length  = 32
  special = false
}

module "database" {
  source = "git::https://github.com/davidfischer-ch/terraform-module-dockerized-postgresql.git?ref=1.3.1"

  identifier = "${var.identifier}-database"
  enabled    = var.enabled
  wait       = var.wait
  image_id   = docker_image.postgresql.image_id

  # Process

  app_uid = var.postgresql_uid
  app_gid = var.postgresql_gid

  # Networking

  hosts      = var.hosts
  network_id = docker_network.app.id

  # Storage

  data_directory = "${var.data_directory}/database"

  # Database

  name = var.identifier

  # Authentication

  user     = var.identifier
  password = random_password.database.result

  # Configuration

  max_connections = var.postgresql_max_connections
}
