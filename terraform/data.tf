# # https://docs.aws.amazon.com/AmazonECS/latest/developerguide/ecs-optimized_AMI.html#ecs-optimized-ami-linux
# data "aws_ssm_parameter" "image_uri" {
#   name = "ecr_artifact_url"
# }

# data "aws_ecr_image" "service_image" {
#   repository_name = module.ecr.repository_name
#   most_recent     = true
# }
# data "aws_ssm_parameter" "ecs_optimized_ami" {
#   name = "/aws/service/ecs/optimized-ami/amazon-linux-2023/recommended"
# }
