resource "random_password" "jwt_secret" {
  length  = 64
  special = false
}

resource "random_password" "postgres_password" {
  length  = 16
  special = false
}
