terraform {
  required_providers {
    null = {
      source  = "hashicorp/null"
      version = ">= 3.0.0"
    }
  }
}

locals {
  install_flags = join(" ", compact([
    "--disable=traefik",
    "--flannel-backend=${var.flannel_backend}",
    var.datastore == "etcd" ? "--cluster-init" : "",
    join(" ", [for san in var.tls_san : "--tls-san=${san}"]),
  ]))
}

resource "null_resource" "k3s_install" {
  triggers = {
    k3s_version   = var.k3s_version
    install_flags = local.install_flags
  }

  connection {
    type = "ssh"
    host = var.ssh_host
    port = var.ssh_port
    user = var.ssh_user
  }

  provisioner "file" {
    source      = "${path.module}/vendor/install.sh"
    destination = "/tmp/k3s-install-script.sh"
  }

  provisioner "file" {
    source      = "${path.module}/install.sh"
    destination = "/tmp/k3s-install.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/k3s-install.sh /tmp/k3s-install-script.sh",
      "/tmp/k3s-install.sh '${var.k3s_version}' '${local.install_flags}'",
      "rm -f /tmp/k3s-install.sh /tmp/k3s-install-script.sh",
    ]
  }
}
