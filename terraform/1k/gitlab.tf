module "gitlab" {
  source = "../modules/gitlab_gcp_instance"

  prefix = "${var.prefix}"
  node_type = "gitlab"
  node_count = 1

  machine_type = "n1-highcpu-16"
  machine_image = "${var.machine_image}"
  label_secondaries = true
}

resource "google_compute_instance_group" "gitlab" {
  name = "${var.prefix}-gitlab-group"

  instances = module.gitlab.self_links

  named_port {
    name = "http"
    port = "80"
  }

  named_port {
    name = "https"
    port = "443"
  }
}

output "gitlab" {
  value = module.gitlab
}
