resource "helm_release" "waypoint_runner" {
  depends_on = [
    local_file.kubeconfig
  ]
  name       = "waypoint-runner"
  repository = "https://helm.releases.hashicorp.com"
  chart      = "waypoint"
  lint       = true
  namespace  = "waypoint"

  set {
    name  = "server.enabled"
    value = false
  }

  set {
    name  = "runner.server.addr"
    value = "api.hashicorp.cloud:443"
  }

  set {
    name  = "runner.server.cookie"
    value = var.waypoint_server_cookie
  }

  set {
    name = "runner.odr.managedNamespaces"
    value = "{waypoint,dev,pre-prod,prod}"
  }

  set {
    name = "runner.odr.serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.aws_ecr_role.arn
    type = "string"
  }

  set {
    name  = "ui.service.enabled"
    value = false
  }
}