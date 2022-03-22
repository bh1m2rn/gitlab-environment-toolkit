output "instance_ids" {
  value = aws_instance.gitlab[*].id
}

output "external_addresses" {
  value = aws_instance.gitlab[*].public_ip
}

output "internal_addresses" {
  value = aws_instance.gitlab[*].private_ip
}

output "iam_instance_role_arn" {
  value = try(aws_iam_role.gitlab[0].arn, "")
}

output "data_disk_device_names" {
  value = [for k, v in aws_volume_attachment.gitlab : "${k} = ${v.device_name}"]
}
