locals {
<<<<<<< HEAD
  create_postgres_kms_key  = var.rds_postgres_instance_type != "" && var.rds_postgres_kms_key_arn == null
  create_postgres_resource = var.rds_postgres_instance_type != "" ? 1 : 0
}

resource "aws_db_subnet_group" "gitlab" {
  count      = local.create_postgres_resource
=======
  postgres_kms_key_create = var.rds_postgres_instance_type != "" && var.rds_postgres_kms_key_arn == null
}

resource "aws_db_subnet_group" "gitlab" {
  count      = var.rds_postgres_instance_type != "" ? 1 : 0
>>>>>>> 5499bf7 (Made changes to reflect labels and tags)
  name       = "${var.prefix}-rds-subnet-group"
  subnet_ids = coalesce(local.subnet_ids, local.default_subnet_ids)

  tags = {
    Name = "${var.prefix}-rds-subnet-group"
  }
}

resource "aws_kms_key" "gitlab_rds_postgres_kms_key" {
<<<<<<< HEAD
  count = local.create_postgres_kms_key ? 1 : 0
=======
  count = local.postgres_kms_key_create ? 1 : 0
>>>>>>> 5499bf7 (Made changes to reflect labels and tags)

  description = "${var.prefix} RDS Postgres KMS Key"

  tags = {
    Name = "${var.prefix}-rds-postgres-kms-key"
  }
}

resource "aws_db_instance" "gitlab" {
<<<<<<< HEAD
  count = local.create_postgres_resource
=======
  count = var.rds_postgres_instance_type != "" ? 1 : 0
>>>>>>> 5499bf7 (Made changes to reflect labels and tags)

  identifier     = "${var.prefix}-rds"
  engine         = "postgres"
  engine_version = var.rds_postgres_version
  instance_class = "db.${var.rds_postgres_instance_type}"
  multi_az       = var.rds_postgres_multi_az
  iops           = var.rds_postgres_iops
  storage_type   = var.rds_postgres_storage_type

  name                 = var.rds_postgres_database_name
  port                 = var.rds_postgres_port
  username             = var.rds_postgres_username
  password             = var.rds_postgres_password
  db_subnet_group_name = aws_db_subnet_group.gitlab[0].name
  vpc_security_group_ids = [
    aws_security_group.gitlab_internal_networking.id
  ]

<<<<<<< HEAD
  replicate_source_db = var.rds_postgres_replication_database_arn
  apply_immediately   = true

  allocated_storage       = var.rds_postgres_allocated_storage
  max_allocated_storage   = var.rds_postgres_max_allocated_storage
  storage_encrypted       = true
  kms_key_id              = local.create_postgres_kms_key ? aws_kms_key.gitlab_rds_postgres_kms_key[0].arn : var.rds_postgres_kms_key_arn
  backup_retention_period = var.rds_postgres_backup_retention_period
=======
  allocated_storage     = var.rds_postgres_allocated_storage
  max_allocated_storage = var.rds_postgres_max_allocated_storage
  storage_encrypted     = true
  kms_key_id            = local.postgres_kms_key_create ? aws_kms_key.gitlab_rds_postgres_kms_key[0].arn : var.rds_postgres_kms_key_arn
>>>>>>> 5499bf7 (Made changes to reflect labels and tags)

  allow_major_version_upgrade = true
  auto_minor_version_upgrade  = false

  skip_final_snapshot = true
<<<<<<< HEAD

  lifecycle {
    ignore_changes = [
      replicate_source_db
    ]
  }
=======
>>>>>>> 5499bf7 (Made changes to reflect labels and tags)
}

output "rds_postgres_connection" {
  value = {
    "rds_address"           = try(aws_db_instance.gitlab[0].address, "")
    "rds_port"              = try(aws_db_instance.gitlab[0].port, "")
    "rds_database_name"     = try(aws_db_instance.gitlab[0].name, "")
    "rds_database_username" = try(aws_db_instance.gitlab[0].username, "")
<<<<<<< HEAD
    "rds_database_arn"      = try(aws_db_instance.gitlab[0].arn, "")
=======
>>>>>>> 5499bf7 (Made changes to reflect labels and tags)
    "rds_kms_key_arn"       = try(aws_db_instance.gitlab[0].kms_key_id, "")
  }
}
