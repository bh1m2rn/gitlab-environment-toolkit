module "gitlab_rails" {
  source = "../../modules/gitlab_gcp_instance"

  prefix = "${var.prefix}"
  node_type = "gitlab-rails"
  node_count = 1

  geo_site = "${var.geo_site}"
  geo_deployment = "${var.geo_deployment}"

  machine_type = "n1-highcpu-8"
  machine_image = "${var.machine_image}"
  label_secondaries = true
}

resource "google_compute_instance_group" "gitlab_rails" {
  name = "${var.prefix}-gitlab-rails-group"

  instances = module.gitlab_rails.self_links

  named_port {
    name = "http"
    port = "80"
  }

  named_port {
    name = "https"
    port = "443"
  }
}

output "gitlab_rails" {
  value = module.gitlab_rails
}
