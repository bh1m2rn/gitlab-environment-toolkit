# module "gitlab-nfs" {
#   source = "../../modules/gitlab_gcp_instance"

#   geo_role = "${var.geo_role}"
#   shared_prefix = "${var.shared_prefix}"
#   prefix = "${var.prefix}"
#   node_type = "gitlab-nfs"
#   node_count = 1

#   disk_type = "pd-ssd"

#   machine_type = "n1-highcpu-4" #TODO: change size
#   machine_image = "${var.machine_image}"
# }

# output "gitlab_nfs" {
#   value = module.gitlab-nfs
# }
