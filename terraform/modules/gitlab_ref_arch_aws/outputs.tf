output "vpc_id" {
  value = aws_vpc.gitlab_vpc.id
}

output "subnets_id" {
  value = aws_subnet.pub[*].id
}

output "subnets_az" {
  value = aws_subnet.pub[*].availability_zone
}

output "subnets_az_id" {
  value = aws_subnet.pub[*].availability_zone_id
}
