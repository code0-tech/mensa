terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }
}

locals {
  notifications = templatefile("${path.module}/notifications.yaml.tftpl", {
    discord_webhook_url = var.discord_webhook_url
    cluster_name        = var.cluster_name
  })
}

resource "null_resource" "flux_operator" {
  triggers = {
    flux_operator_version = var.flux_operator_version
  }

  connection {
    type = "ssh"
    host = var.ssh_host
    port = var.ssh_port
    user = var.ssh_user
  }

  provisioner "file" {
    source      = "${path.module}/vendor/scripts/get-helm-4"
    destination = "/tmp/get-helm.sh"
  }

  provisioner "file" {
    source      = "${path.module}/install-operator.sh"
    destination = "/tmp/flux-install-operator.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/flux-install-operator.sh /tmp/get-helm.sh",
      "/tmp/flux-install-operator.sh '${var.flux_operator_version}'",
      "rm -f /tmp/flux-install-operator.sh /tmp/get-helm.sh",
    ]
  }
}

resource "null_resource" "flux_instance" {
  triggers = {
    flux_operator_ready = null_resource.flux_operator.id
    flux_instance       = sha256(var.flux_instance)
    notifications       = sha256(local.notifications)
  }

  connection {
    type = "ssh"
    host = var.ssh_host
    port = var.ssh_port
    user = var.ssh_user
  }

  provisioner "file" {
    source      = "${path.module}/apply-instance.sh"
    destination = "/tmp/flux-apply-instance.sh"
  }

  provisioner "file" {
    content     = var.flux_instance
    destination = "/tmp/flux-instance.yaml"
  }

  provisioner "file" {
    content     = local.notifications
    destination = "/tmp/flux-notifications.yaml"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/flux-apply-instance.sh",
      "/tmp/flux-apply-instance.sh /tmp/flux-instance.yaml /tmp/flux-notifications.yaml",
      "rm -f /tmp/flux-apply-instance.sh",
    ]
  }
}
