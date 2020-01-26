data "helm_repository" "banzaicloud-stable" {
  count = var.enabled ? 1 : 0
  name  = "banzaicloud-stable"
  url   = "https://kubernetes-charts.banzaicloud.com/"
}

data "template_file" "hollowtrees" {
  count    = var.enabled ? 1 : 0
  template = file("${path.module}/values/values.yaml")

  vars = {
    "pipelineUrl"   = var.pipeline_url
    "telescopesUrl" = var.telescopes_url
    "skipTLSVerify" = var.tls_insecure
    "jwtSigningKey" = var.token_signing_key
    "fqdn"          = var.fqdn
  }
}

resource "helm_release" "hollowtrees" {
  count      = var.enabled ? 1 : 0
  name       = var.release_name
  chart      = var.chart
  repository = data.helm_repository.banzaicloud-stable[0].name
  namespace  = var.namespace

  version = lookup(var.values, "chartVersion", "0.2.0")
  timeout = lookup(var.values, "timeout", "300")
  wait    = lookup(var.values, "wait", "true")

  values = [
    data.template_file.hollowtrees[0].rendered,
    yamlencode(var.values),
  ]
}

