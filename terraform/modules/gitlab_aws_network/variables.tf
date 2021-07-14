# Networking
variable "prefix" { default = "gitlab" }
variable "vpc_cidr_block" { default = "172.31.0.0/16" }
variable "subpub1_cidr_block" { default = "172.31.0.0/20" }
variable "subpub2_cidr_block" { default = "172.31.16.0/20" }
variable "subpub3_cidr_block" { default = "172.31.32.0/20" }
variable "vpc_id" { default = null }
variable "vpc_default" { default = true }
