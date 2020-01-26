data "helm_repository" "stable" {
  count = var.enabled ? 1 : 0
  name  = "stable"
  url   = "https://kubernetes-charts.storage.googleapis.com"
}

data "template_file" "mysql" {
  count = var.enabled ? 1 : 0

  template = file("${path.module}/values/mysql.yaml")

  vars = {
    initializationFilesSecret = kubernetes_secret.mysql-init[0].metadata[0].name
  }
}

resource "kubernetes_secret" "mysql-init" {
  count = var.enabled ? 1 : 0

  metadata {
    name      = "${var.release_name}-init"
    namespace = var.namespace
  }

  data = var.initializationFiles
}

resource "helm_release" "mysql" {
  count      = var.enabled ? 1 : 0
  name       = var.release_name
  chart      = "mysql"
  repository = data.helm_repository.stable[0].name
  namespace  = var.namespace

  version = lookup(var.values, "chartVersion", "1.4.0")
  timeout = lookup(var.values, "timeout", "300")
  wait    = lookup(var.values, "wait", "true")

  values = [
    data.template_file.mysql[0].rendered,
    yamlencode(var.values),
  ]
}

