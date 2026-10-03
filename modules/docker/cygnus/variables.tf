variable "docker_name_prefix" {
  type    = string
  default = ""
}

variable "docker_additional_network_id" {
  type    = string
  default = null
}

variable "web_urls" {
  type = list(string)
}

variable "bind_ip" {
  description = <<-EOT
    Host IP address to bind the published cygnus ports to. Defaults to null,
    which binds on all interfaces (0.0.0.0). Set to "127.0.0.1" to expose the
    ports on localhost only (e.g. when running behind an external reverse
    proxy).
  EOT
  type        = string
  default     = null
}

variable "http_port" {
  description = "Host port mapped to cygnus' internal port 3000. Set to null to not publish HTTP."
  type        = number
  default     = null
}

variable "cygnus_image" {
  type = object({
    name          = string
    sha256_digest = string
  })
}

variable "additional_envs" {
  type    = list(string)
  default = []
}
