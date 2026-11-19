module "proxy" {
  source = "../../modules/docker/proxy"

  certificate_hostnames = [
    "cloud.codezero.build",
    "rest-cloud.codezero.build",
    "crater.codezero.build",
  ]
}
