module "monitor" {
  source = "../../modules/gitlab_gcp_instance"

  prefix = "${var.prefix}"
  node_type = "monitor"
  node_count = 1

  geo_role = "${var.geo_role}"
  geo_group = "${var.geo_group}"

  machine_type = "n1-highcpu-2"
  machine_image = "${var.machine_image}"

  tags = ["${var.prefix}-web", "${var.prefix}-monitor"]
}

output "monitor" {
  value = module.monitor
}
