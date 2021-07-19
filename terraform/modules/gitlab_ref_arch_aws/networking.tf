data "aws_vpc" "selected" {
  id = var.vpc_id
  default = var.vpc_default
}

data "aws_subnet_ids" "all" {
  vpc_id = data.aws_vpc.selected.id
}
