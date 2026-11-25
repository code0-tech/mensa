module "proxy" {
  source = "../../modules/docker/proxy"

  certificate_hostnames = [
    "prod.codezero.build",
    "cloud.codezero.build",
    "rest-cloud.codezero.build",
    "crater.codezero.build",
  ]
}
