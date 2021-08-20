resource "aws_s3_bucket" "gitlab_object_storage_buckets" {
  for_each = toset(var.object_storage_buckets)
  bucket = "${var.prefix}-${each.value}"
  force_destroy = true
}

resource "aws_iam_role" "gitlab_s3_role" {
  count = min(length(var.object_storage_buckets), 1)
  name = "${var.prefix}-s3-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_policy" "gitlab_s3_policy" {
  count = min(length(var.object_storage_buckets), 1)
  name = "${var.prefix}-s3-policy"
  role = aws_iam_role.gitlab_s3_role[0].id

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

resource "aws_iam_instance_profile" "gitlab_s3_profile" {
  count = min(length(var.object_storage_buckets), 1)
  name = "${var.prefix}-s3-profile"
  role = aws_iam_role.gitlab_s3_role[0].name
}

// Service Account Role
data "aws_iam_policy_document" "gitlab_pods_assume_role_policy" {
  count = min(local.total_node_pool_count, 1)

  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"

    condition {
      test = "StringEquals"
      variable = "${replace(aws_iam_openid_connect_provider.gitlab_cluster_openid[count.index].url, "https://", "")}:sub"
      values = ["system:serviceaccount:kube-system:aws-node"]
    }

    principals {
      identifiers = [aws_iam_openid_connect_provider.gitlab_cluster_openid[count.index].arn]
      type = "Federated"
    }
  }
}

resource "aws_iam_role" "gitlab_pods_service_account_role" {
  count = min(local.total_node_pool_count, 1)
  assume_role_policy = data.aws_iam_policy_document.gitlab_pods_assume_role_policy[count.index].json
  name = "${var.prefix}-gitlab_pods_role"
}

resource "aws_iam_role_policy_attachment" "gitlab_pods_policy" {
  count = min(local.total_node_pool_count, 1)
  policy_arn = aws_iam_role_policy.gitlab_s3_policy.arn
  role = aws_iam_role.gitlab_eks_role[0].name
}