module "proxy" {
  source = "../../modules/docker/proxy"

  certificate_hostnames = [
    "codezero.build",
    "cloud.codezero.build",
    "rest-cloud.codezero.build",
    "crater.codezero.build",
  ]

  hostname_config_overrides = [
    {
      hostname = "codezero.build"
      config   = "client_max_body_size 20m;"
    },
  ]
}
