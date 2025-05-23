locals {
  ecr_name = "ecr-ex-${replace(basename(path.cwd), "_", "-")}"

  account_id = data.aws_caller_identity.current.account_id

  ecr_tags = {
    Name = local.name
  }
}

module "ecr" {
  source          = "terraform-aws-modules/ecr/aws"
  version         = "2.3.1"
  repository_name = local.ecr_name

  repository_read_write_access_arns = [data.aws_caller_identity.current.arn]
  repository_lifecycle_policy = jsonencode({
    "rules" : [
      {
        "rulePriority" : 1,
        "description" : "Rule 1",
        "selection" : {
          "tagStatus" : "tagged",
          "tagPatternList" : ["app*"],
          "countType" : "imageCountMoreThan",
          "countNumber" : 3
        },
        "action" : {
          "type" : "expire"
        }
  }] })

  public_repository_catalog_data = {
    description       = "Docker container for some things"
    about_text        = file("${path.module}/ecr_assets/ABOUT.md")
    usage_text        = file("${path.root}/ecr_assets/USAGE.md")
    operating_systems = ["Linux"]
    architectures     = ["x86"]
    logo_image_blob   = filebase64("${path.module}/ecr_assets/clowd.png")
  }
  repository_image_tag_mutability = "MUTABLE"

  tags = local.ecr_tags
}

################################################################################
# ECR Registry
################################################################################

data "aws_iam_policy_document" "registry" {
  #   Callers can reference our repository and pull our private images
  #   https://github.com/aws-actions/amazon-ecr-login/tree/v2.0.1?tab=readme-ov-file#ecr-private
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }

    actions = [
      "ecr:GetAuthorizationToken",
      "ecr:ReplicateImage",
      "ecr:BatchImportUpstreamImage",
      "ecr:CreateRepository",
      "ecr:BatchGetImage",
      "ecr:BatchCheckLayerAvailability",
      "ecr:CompleteLayerUpload",
      "ecr:GetDownloadUrlForLayer",
      "ecr:InitiateLayerUpload",
      "ecr:PutImage",
      "ecr:UploadLayerPart"
    ]
    resources = ["${module.ecr.repository_arn}/*"]
  }

}
