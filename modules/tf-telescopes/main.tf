data "helm_repository" "banzaicloud-stable" {
  count = var.enabled ? 1 : 0
  name  = "banzaicloud-stable"
  url   = "https://kubernetes-charts.banzaicloud.com/"
}

data "template_file" "telescopes" {
  count    = var.enabled ? 1 : 0
  template = file("${path.module}/values/telescopes.yaml")

  vars = {
    "cloudinfoUrl" = var.cloudinfo_url
  }
}

resource "helm_release" "telescopes" {
  count      = var.enabled ? 1 : 0
  name       = var.release_name
  chart      = "telescopes"
  repository = data.helm_repository.banzaicloud-stable[0].name
  namespace  = var.namespace

  version = lookup(var.values, "chartVersion", "0.1.13")
  timeout = lookup(var.values, "timeout", "300")
  wait    = lookup(var.values, "wait", "true")

  values = [
    data.template_file.telescopes[0].rendered,
    yamlencode(var.values),
  ]
}

