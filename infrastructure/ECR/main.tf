resource "aws_ecr_repository" "docker_image_repo" {
  name                 = "hackathon-2024"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

