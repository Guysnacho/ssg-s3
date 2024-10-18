locals {
  ecr_name = "ecr-ex-${replace(basename(path.cwd), "_", "-")}"

  account_id = data.aws_caller_identity.current.account_id

  ecr_tags = {
    Name       = local.name
    Repository = "https://github.com/terraform-aws-modules/terraform-aws-ecr"
  }
}

data "aws_ssm_parameter" "image_url" {
  name = "ecr_artifact_url"
}

module "public_ecr" {
  source = "terraform-aws-modules/ecr/aws"

  repository_name = local.ecr_name
  repository_type = "private"

  repository_read_write_access_arns = [data.aws_caller_identity.current.arn]
  create_registry_policy            = true

  public_repository_catalog_data = {
    description       = "Docker container for some things"
    about_text        = file("${path.module}/fixtures/ecr_assets/ABOUT.md")
    usage_text        = file("${path.module}/fixtures/ecr_assets/USAGE.md")
    operating_systems = ["Linux"]
    architectures     = ["x86"]
    logo_image_blob   = filebase64("${path.module}/fixtures/ecr_assets/clowd.png")
  }

  tags = local.ecr_tags
}

################################################################################
# ECR Registry
################################################################################

data "aws_iam_policy_document" "registry" {
  #   Callers can reference our repository
  statement {
    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }

    actions   = ["ecr:ReplicateImage"]
    resources = [module.ecr.repository_arn]
  }

  #   Callers can create repositories
  statement {
    sid = "pub"

    principals {
      type        = "AWS"
      identifiers = ["arn:aws:iam::${local.account_id}:root"]
    }
    actions = [
      "ecr:CreateRepository",
      "ecr:BatchImportUpstreamImage"
    ]
    resources = [data.aws_ssm_parameter.image_url.value]
  }
}
