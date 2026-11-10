resource "kubernetes_secret_v1" "sensitive_values" {
  metadata {
    namespace = kubernetes_namespace_v1.this.metadata[0].name
    name      = "gitlab-runner-token"
  }

  data = {
    runner-token = var.runner_token
    runner-registration-token = ""
  }
}
