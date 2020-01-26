resource "random_string" "postgresql-replication-password" {
  count   = var.enabled ? 1 : 0
  length  = 16
  special = true
}

resource "random_string" "postgresql-password" {
  count   = var.enabled ? 1 : 0
  length  = 16
  special = false
}

resource "kubernetes_secret" "postgresql-passwords" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "${var.release_name}-passwords"
    namespace = var.namespace
  }

  data = {
    postgresql-password             = random_string.postgresql-password[0].result
    postgresql-replication-password = random_string.postgresql-replication-password[0].result
  }
}

resource "kubernetes_secret" "postgresql-init" {
  count = var.enabled ? 1 : 0
  metadata {
    name      = "${var.release_name}-init"
    namespace = var.namespace
  }

  data = var.initScripts
}

# Prepare helm values for feature_set
data "template_file" "postgress" {
  count    = var.enabled ? 1 : 0
  template = file("${path.module}/values/values.yaml")

  vars = {
    "existingSecret" : kubernetes_secret.postgresql-passwords[0].metadata[0].name
    "postgresqlUsername" : var.username
    "postgresqlDatabase" : var.database
    "initdbScriptsSecret" : kubernetes_secret.postgresql-init[0].metadata[0].name
  }
}

data "helm_repository" "stable" {
  count = var.enabled ? 1 : 0
  name  = "stable"
  url   = "https://kubernetes-charts.storage.googleapis.com"
}

resource "helm_release" "postgresql" {
  count = var.enabled ? 1 : 0

  name       = var.release_name
  chart      = "postgresql"
  repository = data.helm_repository.stable[0].name
  namespace  = var.namespace

  version = lookup(var.values, "chartVersion", "6.5.8")
  timeout = lookup(var.values, "timeout", "300")
  wait    = lookup(var.values, "wait", "true")

  values = [
    data.template_file.postgress[0].rendered,
    yamlencode(var.values)
  ]
}

