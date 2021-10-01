variable "prefix" {
  type = string
}
variable "node_type" {
  type = string
}

variable "node_count" {
  type    = number
  default = 1
}

variable "instance_type" {
  type    = string
  default = "S3"
}

variable "image_id" {
  type    = string
  default = null
}

variable "security_group_ids" {
  type    = list(string)
  default = []
}

variable "vpc_id" {
  type    = string
  default = null
}

variable "subnet_id" {
  type    = string
  default = null
}

variable "ssh_key_name" {
  type    = string
  default = null
}

variable "disk_type" {
  type    = string
  default = "CLOUD_PREMIUM"
}

variable "disk_size" {
  type    = string
  default = "100"
}

variable "label_secondaries" {
  type    = bool
  default = false
}

variable "geo_site" {
  type    = string
  default = null
}

variable "geo_deployment" {
  type    = string
  default = null
}

variable "data_disk_type" {
  type    = string
  default = "CLOUD_SSD"
}

variable "data_disk_size" {
  type    = number
  default = null
}
