resource "docker_network" "app" {
  name     = var.identifier
  driver   = "bridge"
  internal = false
}
