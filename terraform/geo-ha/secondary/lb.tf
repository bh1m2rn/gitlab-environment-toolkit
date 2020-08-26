# # https://binx.io/blog/2018/11/19/how-to-configure-global-load-balancing-with-google-cloud-platform/

# resource "google_compute_global_address" "gitlab" {
#   name = "${var.prefix}-gitlab-rails-global-address"
# }

# resource "google_dns_record_set" "frontend" {
#   name = "" # TODO: CHANGEME, ALSO DEFINED IN ansible/group_vars/geo_role_primary.yml AND /geo_role_secondary.yml
#   type = "A"
#   ttl  = 300

#   managed_zone = "gogitlabml" # TODO: CHANGEME

#   rrdatas = [google_compute_global_address.gitlab.address]
# }

# resource "google_compute_global_forwarding_rule" "gitlab" {
#   name       = "${var.prefix}-gitlab-rails-rule-80"
#   ip_address = google_compute_global_address.gitlab.address
#   port_range = "80"
#   target     = google_compute_target_http_proxy.gitlab.self_link
# }

# resource "google_compute_target_http_proxy" "gitlab" {
#   name    = "${var.prefix}-gitlab-rails-target-http-proxy"
#   url_map = google_compute_url_map.gitlab.self_link
# }

# resource "google_compute_url_map" "gitlab" {
#   name        = "${var.prefix}-gitlab-rails-url-map"
#   default_service = google_compute_backend_service.gitlab.self_link
# }

# resource "google_compute_backend_service" "gitlab" {
#   name        = "${var.prefix}-gitlab-rails-backend-service"
#   port_name   = "http"
#   protocol    = "HTTP"
#   timeout_sec = 30

#   backend {
#     group = google_compute_instance_group.gitlab_rails.self_link
#   }

#   health_checks = [google_compute_health_check.gitlab.self_link]
# }

# resource "google_compute_health_check" "gitlab" {
#   name = "${var.prefix}-gitlab-rails-health-check"

#   timeout_sec        = 5
#   check_interval_sec = 5

#   http_health_check {
#     port = 80
#     request_path = "/help"
#   }
# }

# output "gitlab-rails-load-balancer-ip" {
#   value = google_compute_global_address.gitlab.address
# }
