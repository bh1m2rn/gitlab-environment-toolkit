module "praefect" {
  source = "../modules/gitlab_gcp_instance"

  prefix = "${var.prefix}"
  node_type = "praefect"
  node_count = 3

  machine_type = "n1-highcpu-2"
  machine_image = "${var.machine_image}"
  label_secondaries = true
}

output "praefect" {
  value = module.praefect
}
