variable "server_administration_ip" {
  type      = string
  sensitive = true
}

variable "server_administration_ssh_port" {
  type      = string
  sensitive = true
}

variable "gitlab_api_token" {
  type      = string
  sensitive = true
}
