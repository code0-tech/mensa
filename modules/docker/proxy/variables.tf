variable "certificate_hostnames" {
  type = set(string)
}

variable "hostname_config_overrides" {
  type = list(object({
    hostname = string
    config = string
  }))

  default = []
}
