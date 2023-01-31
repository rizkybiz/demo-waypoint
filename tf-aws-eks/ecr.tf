resource "aws_ecr_repository" "waypoint_container_repository" {
  name                 = "demo-waypoint"
  image_tag_mutability = "MUTABLE"
}