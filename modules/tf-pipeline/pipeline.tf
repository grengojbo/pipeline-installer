data "helm_repository" "banzaicloud-stable" {
  name = "banzaicloud-stable"
  url  = "https://kubernetes-charts.banzaicloud.com/"
}

resource "random_string" "tokensigningkey" {
  length  = 32
  special = false
}

# Prepare helm values for feature_set
data "template_file" "pipeline" {
  template = file("${path.module}/values/pipeline.yaml")

  vars = {
    image_tag = var.image_tag

    token_signing_key = random_string.tokensigningkey.result
    dex_url           = var.dex_url
    dex_client_id     = var.dex_client_id
    dex_client_secret = var.dex_client_secret
    dex_api_address   = var.dex_api_address
    cloudinfo_url     = var.cloudinfo_url
    external_url      = "${var.cp_scheme}://${var.fqdn}/pipeline"
    cicd_url          = "${var.cp_scheme}://${var.fqdn}/build"
    fqdn              = var.fqdn
    vault_address     = var.vault_address
    tls_insecure      = var.tls_insecure
    cpu               = var.cpu

    database_driver   = var.database_driver
    database_name     = var.database_name
    database_username = var.database_username
    database_password = var.database_password
    database_host     = var.database_host
    database_port     = var.database_port

    hollowtrees_url               = var.hollowtrees_url
    hollowtrees_token_signing_key = var.hollowtrees_token_signing_key
  }
}

resource "helm_release" "pipeline" {
  name       = var.release_name
  chart      = "pipeline"
  repository = data.helm_repository.banzaicloud-stable.name
  namespace  = var.namespace

  version = lookup(var.values, "chartVersion", "0.4.0")
  timeout = lookup(var.values, "timeout", "300")
  wait    = lookup(var.values, "wait", "true")

  values = [
    data.template_file.pipeline.rendered,
    yamlencode({ "hostAliases" : var.host_aliases }),
    yamlencode(var.values)
  ]
}

