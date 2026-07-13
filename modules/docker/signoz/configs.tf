resource "docker_volume" "signoz_configs" {
  name = "signoz-configs"
}

resource "docker_image" "alpine" {
  name = "alpine:3.21"
}

resource "docker_container" "config_writer" {
  image    = docker_image.alpine.image_id
  name     = "signoz-config-writer"
  must_run = false

  upload {
    file    = "/configs/ingester/ingester.yaml"
    content = file("${path.module}/pours/deployment/ingester/ingester.yaml")
  }

  upload {
    file    = "/configs/ingester/opamp.yaml"
    content = file("${path.module}/pours/deployment/ingester/opamp.yaml")
  }

  upload {
    file    = "/configs/telemetrykeeper/clickhousekeeper/keeper-0.yaml"
    content = file("${path.module}/pours/deployment/telemetrykeeper/clickhousekeeper/keeper-0.yaml")
  }

  upload {
    file    = "/configs/telemetrystore/clickhouse/config-0-0.yaml"
    content = file("${path.module}/pours/deployment/telemetrystore/clickhouse/config-0-0.yaml")
  }

  upload {
    file    = "/configs/telemetrystore/clickhouse/functions.yaml"
    content = file("${path.module}/pours/deployment/telemetrystore/clickhouse/functions.yaml")
  }

  volumes {
    volume_name    = docker_volume.signoz_configs.name
    container_path = "/signoz-configs"
  }

  command = [
    "sh", "-c",
    "cp -r /configs/* /signoz-configs/ && echo 'Config files written successfully'"
  ]
}
