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

variable "stripe_staging_api_key" {
  type      = string
  sensitive = true
}

variable "server_staging_ip" {
  type      = string
  sensitive = true
}

variable "server_staging_ssh_port" {
  type      = string
  sensitive = true
}
