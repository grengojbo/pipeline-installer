data "template_file" "vault" {
  count    = var.enabled ? 1 : 0
  template = file("${path.module}/values/vault.yaml")

  vars = {
    namespace = var.namespace
  }
}

data "template_file" "vault-storage" {
  count = var.enabled ? 1 : 0

  template = file("${path.module}/values/vault-storage-${var.database_driver}.yaml")

  vars = {
    database_host     = var.database_host
    database_name     = var.database_name
    database_username = var.database_username
    database_password = var.database_password
    database_port     = var.database_port
  }
}

data "helm_repository" "banzaicloud-stable" {
  count = var.enabled ? 1 : 0
  name  = "banzaicloud-stable"
  url   = "https://kubernetes-charts.banzaicloud.com/"
}

resource "helm_release" "vault" {
  count      = var.enabled ? 1 : 0
  name       = var.release_name
  chart      = "vault"
  repository = data.helm_repository.banzaicloud-stable[0].name
  namespace  = var.namespace

  version = lookup(var.values, "chartVersion", "0.6.10")
  timeout = lookup(var.values, "timeout", "300")
  wait    = lookup(var.values, "wait", "true")

  values = [
    data.template_file.vault[0].rendered,
    data.template_file.vault-storage[0].rendered,
    yamlencode(var.values),
  ]
}

resource "kubernetes_ingress" "vault" {
  count = var.enabled && var.ingress_enabled ? 1 : 0

  metadata {
    name      = var.release_name
    namespace = var.namespace

    annotations = {
      "kubernetes.io/ingress.class"    = "traefik"
      "ingress.kubernetes.io/protocol" = "https"
      "traefik.frontend.rule.type"     = "PathPrefixStrip"
    }
  }

  spec {
    rule {
      http {
        path {
          backend {
            service_name = var.release_name
            service_port = 8200
          }

          path = "/vault/"
        }
      }
    }
  }
}
