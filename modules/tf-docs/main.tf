data "helm_repository" "banzaicloud-stable" {
  count = var.enabled ? 1 : 0
  name  = "banzaicloud-stable"
  url   = "https://kubernetes-charts.banzaicloud.com/"
}

# Prepare helm values for docs
data "template_file" "docs" {
  count    = var.enabled ? 1 : 0
  template = file("${path.module}/values/docs.yaml")
  vars = {
    image_tag         = var.image_tag
    image_pull_policy = var.image_pull_policy
    fqdn              = var.fqdn
    keel_notify       = var.keel_notify
    keel_policy       = var.keel_policy
    keel_trigger      = var.keel_trigger
    keel_approvals    = var.keel_approvals
  }
}

resource "helm_release" "docs" {
  count      = var.enabled ? 1 : 0
  name       = var.release_name
  version    = "0.1.2"
  chart      = "banzaicloud-docs"
  repository = data.helm_repository.banzaicloud-stable[0].name
  namespace  = var.namespace
  timeout    = lookup(var.values, "timeout", "300")
  wait       = lookup(var.values, "wait", "false")

  values = [
    data.template_file.docs[0].rendered,
    yamlencode(var.values),
  ]
}

