resource "aws_s3_bucket" "gitlab_object_storage_buckets" {
  for_each      = toset(var.object_storage_buckets)
  bucket        = "${var.prefix}-${each.value}"
  force_destroy = var.object_storage_force_destroy

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm     = "aws:kms"
        kms_master_key_id = var.object_storage_kms_key_arn != null ? var.object_storage_kms_key_arn : var.default_kms_key_arn
      }
      bucket_key_enabled = true
    }
  }

  tags = var.object_storage_tags
}

# IAM Policies
locals {
  gitlab_s3_policy_create          = length(var.object_storage_buckets) > 0
  gitlab_s3_registry_policy_create = length(var.object_storage_buckets) > 0 && contains(var.object_storage_buckets, "registry")
  gitlab_s3_kms_policy_create      = length(var.object_storage_buckets) > 0 && (var.object_storage_kms_key_arn != null || var.default_kms_key_arn != null)

  gitlab_s3_policy_arns = flatten([
    local.gitlab_s3_policy_create ? [aws_iam_policy.gitlab_s3_policy[0].arn] : [],
    local.gitlab_s3_registry_policy_create ? [aws_iam_policy.gitlab_s3_registry_policy[0].arn] : [],
    local.gitlab_s3_kms_policy_create ? [aws_iam_policy.gitlab_s3_kms_policy[0].arn] : []
  ])
}

resource "aws_iam_policy" "gitlab_s3_policy" {
  count = local.gitlab_s3_policy_create ? 1 : 0
  name  = "${var.prefix}-s3-policy"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "s3:PutObject",
          "s3:GetObject",
          "s3:DeleteObject",
        ]
        Effect   = "Allow"
        Resource = concat([for bucket in aws_s3_bucket.gitlab_object_storage_buckets : bucket.arn], [for bucket in aws_s3_bucket.gitlab_object_storage_buckets : "${bucket.arn}/*"])
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "gitlab_s3_role_policy_attachment" {
  count      = min(length(var.object_storage_buckets), 1)
  policy_arn = aws_iam_policy.gitlab_s3_policy[0].arn
  role       = aws_iam_role.gitlab_s3_role[0].name
}

resource "aws_iam_instance_profile" "gitlab_s3_profile" {
  count = min(length(var.object_storage_buckets), 1)
  name  = "${var.prefix}-s3-profile"
  role  = aws_iam_role.gitlab_s3_role[0].name
}

output "gitlab_s3_role" {
  value = try(aws_iam_role.gitlab_s3_role[0].name, null)
}