variable "cloudflare_api_token" {
  type      = string
  sensitive = true
}

variable "cloudflare_account_id" {
  type      = string
  sensitive = true
}

variable "gitlab_api_token" {
  type      = string
  sensitive = true
}

variable "server_production_ip" {
  type      = string
  sensitive = true
}

variable "server_production_ssh_port" {
  type      = string
  sensitive = true
}
