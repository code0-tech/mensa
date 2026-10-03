variable "docker_proxy_network_id" {
  type = string
}

variable "web_urls" {
  type = list(string)
}

variable "cygnus_image" {
  type = object({
    name          = string
    sha256_digest = string
  })
}
