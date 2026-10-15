resource "docker_network" "cygnus" {
  name = "${var.docker_name_prefix}cygnus"
}
