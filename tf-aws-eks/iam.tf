data "aws_caller_identity" "current" {}

data "aws_iam_policy_document" "ecr_policy_document" {
  statement {
    actions = [
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart",
      "ecr:DescribeRepositories"
    ]
    resources = [
      aws_ecr_repository.waypoint_container_repository.arn
    ]
  }
  statement {
    actions = [
      "ecr:GetAuthorizationToken"
    ]
    resources = [
      "*"
    ]
  }
}

data "aws_iam_policy_document" "iam__k8s_sa_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type = "Federated"
      identifiers = [
        "arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${trimprefix(module.eks.cluster_oidc_issuer_url, "https://")}"
      ]
    }
    condition {
      test     = "StringEquals"
      variable = "${trimprefix(module.eks.cluster_oidc_issuer_url, "https://")}:sub"
      values = [
        "system:serviceaccount:waypoint:waypoint-runner-runner-odr"
      ]
    }
  }
}

resource "aws_iam_role" "aws_ecr_role" {
  name               = "aws-ecr-role"
  assume_role_policy = data.aws_iam_policy_document.iam__k8s_sa_assume_role.json
  inline_policy {
    name   = "AllowECR"
    policy = data.aws_iam_policy_document.ecr_policy_document.json
  }
}