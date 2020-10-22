module "redis" {
  source = "../../modules/gitlab_gcp_instance"

  prefix = "${var.prefix}"
  node_type = "redis"
  node_count = 3

  geo_role = "${var.geo_role}"
  geo_group = "${var.geo_group}"

  machine_type = "n1-standard-2"
  machine_image = "${var.machine_image}"
  label_secondaries = true
}

output "redis" {
  value = module.redis
}