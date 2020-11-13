module "gitlab-nfs" {
  source = "../../modules/gitlab_gcp_instance"

  prefix = "${var.prefix}"
  node_type = "gitlab-nfs"
  node_count = 1

  disk_type = "pd-ssd"

  geo_site = "${var.geo_site}"
  geo_deployment = "${var.geo_deployment}"

  machine_type = "n1-highcpu-4"
  machine_image = "${var.machine_image}"
}

output "gitlab_nfs" {
  value = module.gitlab-nfs
}
