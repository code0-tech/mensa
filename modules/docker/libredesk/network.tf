resource "docker_network" "libredesk" {
  name = "${var.docker_name_prefix}libredesk"
}
