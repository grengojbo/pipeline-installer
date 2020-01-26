data "helm_repository" "stable" {
  name = "stable"
  url  = "https://kubernetes-charts.storage.googleapis.com"
}

locals {
  image           = lookup(var.values, "image", {})
  anchoreGlobal   = lookup(var.values, "anchoreGlobal", {})
  anchorePassword = lookup(local.anchoreGlobal, "defaultAdminPassword", "")
  anchoreEmail    = lookup(local.anchoreGlobal, "defaultAdminEmail", "")
}

data "template_file" "anchore" {
  count    = var.enabled ? 1 : 0
  template = file("${path.module}/values/anchore.yaml")

  vars = {
    fqdn = var.fqdn

    admin_password = var.admin_password
    admin_email    = var.admin_email

    database_name     = var.database_name
    database_username = var.database_username
    database_password = var.database_password
    database_host     = var.database_host
    database_port     = var.database_port

    image_name = lookup(local.image, "name", "docker.io/anchore/anchore-engine")
    image_tag  = lookup(local.image, "tag", "v0.3.3")
  }
}

resource "helm_release" "anchore" {
  count = var.enabled ? 1 : 0
  name  = var.release_name
  chart = "anchore-engine"

  namespace = var.namespace

  repository = data.helm_repository.stable.name

  version = lookup(var.values, "chartVersion", "0.13.0")
  timeout = lookup(var.values, "timeout", "300")
  wait    = lookup(var.values, "wait", "true")

  values = [
    data.template_file.anchore[0].rendered,
    yamlencode(var.values),
  ]

  depends_on = [data.helm_repository.stable]
}

