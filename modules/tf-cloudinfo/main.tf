resource "kubernetes_service_account" "cloudinfo" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "cloudinfo"
    namespace = var.namespace
  }
  automount_service_account_token = true
}

data "helm_repository" "banzaicloud-stable" {
  count = var.enabled ? 1 : 0
  name  = "banzaicloud-stable"
  url   = "https://kubernetes-charts.banzaicloud.com/"
}

data "template_file" "cloudinfo" {
  count    = var.enabled ? 1 : 0
  template = file("${path.module}/values/cloudinfo.yaml")

  vars = {
    vaultAddress = var.vaultAddress
  }
}

resource "helm_release" "cloudinfo" {
  count      = var.enabled ? 1 : 0
  name       = var.release_name
  chart      = "cloudinfo"
  repository = data.helm_repository.banzaicloud-stable[0].name
  namespace  = var.namespace

  version = lookup(var.values, "chartVersion", "0.6.6")
  timeout = lookup(var.values, "timeout", "300")
  wait    = lookup(var.values, "wait", "false")

  values = [
    data.template_file.cloudinfo[0].rendered,
    yamlencode(var.values),
  ]
}