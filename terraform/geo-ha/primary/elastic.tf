module "elastic" {
  source = "../../modules/gitlab_gcp_instance"

  geo_role = "${var.geo_role}"
  shared_prefix = "${var.shared_prefix}"
  prefix = "${var.prefix}"
  node_type = "elastic"
  node_count = 1

  disk_type = "pd-ssd"
  # disk_size = "500" #TODO: change size

  # machine_type = "n1-highcpu-8" #TODO: change size
  machine_image = "${var.machine_image}"
  label_non_main_nodes = true

  tags = ["${var.prefix}-web", "${var.prefix}-elastic"]
}

output "elastic" {
  value = module.elastic
}