resource "random_string" "dex_client_secret" {
  length  = 32
  special = false
}

data "template_file" "dex" {
  template = file("${path.module}/values/dex.yaml")

  vars = {
    ingress_class = var.ingress_class
    issuer_url    = var.issuer_url
  }
}

data "template_file" "dex-storage-k8s" {
  template = var.storage_type == "kubernetes" ? file("${path.module}/values/dex-storage-k8s.yaml") : ""
  vars     = {}
}

data "template_file" "dex-storage-sql" {
  template = (var.storage_type == "postgres" || var.storage_type == "mysql") ? file("${path.module}/values/dex-storage-sql.yaml") : ""

  vars = {
    type     = var.storage_type
    host     = var.storage_host
    port     = var.storage_port
    database = var.storage_database
    username = var.storage_username
    password = var.storage_password
    sslmode  = var.storage_sslmode
  }
}

locals {
  connectors = keys(lookup(lookup(var.values, "config", {}), "connectors", {}))
}

data "template_file" "connector_github" {
  template = contains(local.connectors, "publicGithub") ? file("${path.module}/values/dex-github.yaml") : ""

  vars = {
    clientID     = var.github_client_id
    clientSecret = var.github_client_secret
    redirectURI  = "${var.issuer_url}/callback"
  }
}

data "template_file" "connector_google" {
  template = contains(local.connectors, "google") ? file("${path.module}/values/dex-google.yaml") : ""

  vars = {
    redirectURI = "${var.issuer_url}/callback"
  }
}

data "template_file" "connector_static" {
  template = length(local.connectors) < 1 ? file("${path.module}/values/dex-password.yaml") : ""

  vars = {
    email    = var.static_email
    username = var.static_username
    hash     = bcrypt(var.static_password)
  }
}

data "helm_repository" "banzaicloud-stable" {
  name = "banzaicloud-stable"
  url  = "https://kubernetes-charts.banzaicloud.com/"
}

resource "helm_release" "dex" {
  name         = var.release_name
  chart        = "dex"
  repository   = data.helm_repository.banzaicloud-stable.name
  namespace    = var.namespace
  version      = lookup(var.values, "chartVersion", "0.1.0")
  timeout      = lookup(var.values, "timeout", "300")
  wait         = lookup(var.values, "wait", "true")
  reuse_values = false

  set {
    name  = "config.staticClients[0].name"
    value = "Banzai Cloud Pipeline"
  }

  set {
    name  = "config.staticClients[0].id"
    value = var.dex_client_id
  }

  set {
    name  = "config.staticClients[0].secret"
    value = random_string.dex_client_secret.result
  }

  set {
    name  = "config.staticClients[0].redirectURIs[0]"
    value = var.dex_client_redirect_uri
  }

  values = [
    data.template_file.dex.rendered,
    data.template_file.dex-storage-sql.rendered,
    data.template_file.dex-storage-k8s.rendered,
    data.template_file.connector_github.rendered,
    data.template_file.connector_static.rendered,
    data.template_file.connector_google.rendered,
    yamlencode(var.values),
  ]
}