data "helm_repository" "banzaicloud-stable" {
  count = var.enabled ? 1 : 0
  name  = "banzaicloud-stable"
  url   = "https://kubernetes-charts.banzaicloud.com/"
}

# Prepare helm values for feature_set
data "template_file" "cicd" {
  count    = var.enabled ? 1 : 0
  template = file("${path.module}/values/cicd.yaml")

  vars = {
    fqdn              = var.fqdn
    tls_insecure      = var.tls_insecure
    database_driver   = var.database_driver
    database_name     = var.database_name
    database_username = var.database_username
    database_password = var.database_password
    database_host     = var.database_host
    database_port     = var.database_port
  }
}

resource "helm_release" "cicd" {
  count      = var.enabled ? 1 : 0
  name       = var.release_name
  version    = lookup(var.values, "chartVersion", "2.0.4")
  chart      = "cicd"
  repository = data.helm_repository.banzaicloud-stable[0].name
  namespace  = var.namespace
  timeout    = lookup(var.values, "timeout", "300")
  wait       = lookup(var.values, "wait", "true")

  values = [
    data.template_file.cicd[0].rendered,
    yamlencode(var.values)
  ]
}
