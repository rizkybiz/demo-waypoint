variable "cluster_name" {
  type    = string
  default = "waypoint-demo-k8s"
}

variable "region" {
  type    = string
  default = "us-east-2"
}

variable "waypoint_server_cookie" {
  type = string
}