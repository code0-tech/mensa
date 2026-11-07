resource "random_password" "clickhouse_password" {
  length  = 32
  special = false
}

resource "kubernetes_secret_v1" "sensitive_values" {
  metadata {
    namespace = "flux-system"
    name      = "sensitive-signoz-chart-values"
    labels = {
      "reconcile.fluxcd.io/watch" = "Enabled"
    }
  }

  data = {
    clickhouse_password = random_password.clickhouse_password.result
  }
}
