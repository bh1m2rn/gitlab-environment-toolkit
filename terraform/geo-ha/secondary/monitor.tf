module "monitor" {
  source = "../../modules/gitlab_gcp_instance"

  geo_role = "${var.geo_role}"
  shared_prefix = "${var.shared_prefix}"
  prefix = "${var.prefix}"
  node_type = "monitor"
  node_count = 1

  # machine_type = "n1-highcpu-2" #TODO: change size
  machine_image = "${var.machine_image}"

  tags = ["${var.prefix}-web", "${var.prefix}-monitor"]
}

output "monitor" {
  value = module.monitor
}
