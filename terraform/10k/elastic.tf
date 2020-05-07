module "elastic" {
  source = "../modules/gitlab_gcp_instance"

  prefix = "${var.prefix}"
  node_type = "elastic"
  node_count = 3

  disk_type = "pd-ssd"
  disk_size = "500"

  machine_type = "n1-highcpu-16"
  machine_image = "${var.machine_image}"
  label_secondaries = true

  tags = ["${var.prefix}-web", "${var.prefix}-elastic"]
}

output "elastic" {
  value = module.elastic
}