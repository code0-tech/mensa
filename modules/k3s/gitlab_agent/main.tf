terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }
}

locals {
  manifests = templatefile("${path.module}/manifests.yaml.tftpl", {
    namespace     = var.namespace
    agent_token   = var.agent_token
    agent_version = var.agent_version
    kas_address   = var.kas_address
  })
}

resource "null_resource" "gitlab_agent" {
  triggers = {
    manifests = sha256(local.manifests)
  }

  connection {
    type = "ssh"
    host = var.ssh_host
    port = var.ssh_port
    user = var.ssh_user
  }

  provisioner "file" {
    source      = "${path.module}/apply.sh"
    destination = "/tmp/gitlab-agent-apply.sh"
  }

  provisioner "file" {
    content     = local.manifests
    destination = "/tmp/gitlab-agent.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/gitlab-agent-apply.sh",
      "/tmp/gitlab-agent-apply.sh /tmp/gitlab-agent.yaml",
      "rm -f /tmp/gitlab-agent-apply.sh",
    ]
  }
}
