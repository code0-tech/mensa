resource "docker_network" "otel_agent" {
  name = "${var.docker_name_prefix}otel_agent"
}
