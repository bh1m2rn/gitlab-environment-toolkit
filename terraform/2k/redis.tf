module "redis" {
  source = "../modules/gitlab_gcp_instance"

  prefix = "${var.prefix}"
  node_type = "redis"
  node_count = 1

  machine_type = "n1-standard-1"
  machine_image = "${var.machine_image}"
  label_secondaries = true
}

output "redis" {
  value = module.redis
}
