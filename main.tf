// Copyright © 2019 Banzai Cloud
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

locals {
  scheme = lookup(local.values, "scheme", "https")

  host = {
    "ec2"    = lookup(local.values, "externalHost", "auto") == "auto" ? module.ec2.host : lookup(local.values, "externalHost", ""),
    "k8s"    = lookup(local.values, "externalHost", "auto") == "auto" ? module.traefik.url : lookup(local.values, "externalHost", "")
    "custom" = lookup(local.values, "externalHost", "auto") == "auto" ? module.traefik.url : lookup(local.values, "externalHost", "")
  }

  externalHost = lookup(local.host, local.provider, lookup(local.values, "externalHost", "default.localhost.banzaicloud.io"))

  tlsInsecure    = lookup(local.values, "tlsInsecure", "true")
  provider       = lookup(local.values, "provider", "")
  providerConfig = lookup(local.values, "providerConfig", {})

  // Leave this here temporarily to be compatible with older CLI versions, that does not yet generate merged values
  valuesFileName    = fileexists("${var.workdir}/generated-values.yaml") ? "${var.workdir}/generated-values.yaml" : "${var.workdir}/values.yaml"
  valuesFileNameCLI = fileexists("${var.workdir}/generated-values-cli.yaml") ? "${var.workdir}/generated-values-cli.yaml" : local.valuesFileName

  values = yamldecode(file(local.valuesFileNameCLI))

  cloudinfoUrl  = local.hasCloudinfo ? "${local.scheme}://${local.externalHost}/cloudinfo" : "${local.scheme}://beta.banzaicloud.io/cloudinfo"
  telescopesUrl = local.hasTelescopes ? "${local.scheme}://${local.externalHost}/recommender" : "${local.scheme}://beta.banzaicloud.io/recommender"

  hasHollowtrees = lookup(lookup(local.values, "hollowtrees", {}), "enabled", "false")

  hasTelescopes = lookup(lookup(local.values, "telescopes", {}), "enabled", "false")
  hasCloudinfo  = lookup(lookup(local.values, "cloudinfo", {}), "enabled", "false")

  defaultStorageBackend = lookup(local.values, "defaultStorageBackend", "postgres")
  
  rootDatabaseHost = lookup(local.values, "rootDatabaseHost", "none")
  rootDatabasePassword = lookup(local.values, "rootDatabasePassword", "root")
  rootDatabaseUser = lookup(local.values, "rootDatabaseUser", "postgres")

  database = {
    host = lookup(lookup(local.databaseInfo, local.defaultStorageBackend, "{}"), "host", "")
    port = lookup(lookup(local.databaseInfo, local.defaultStorageBackend, "{}"), "port", "")
  }

  databaseInfo = {
    postgres = {
      host = module.postgresql.host
      port = module.postgresql.port
    }

    mysql = {
      host = module.mysql.host
      port = module.mysql.port
    }
  }
}

module "cadence" {
  source             = "./modules/tf-cadence"
  namespace          = kubernetes_deployment.tiller.metadata[0].namespace
  persistence_driver = "sql"
  install_cassandra  = false

  sql_host     = local.databaseInfo.mysql.host
  sql_port     = local.databaseInfo.mysql.port
  sql_user     = "cadence"
  sql_password = random_string.cadence-db-password.result

  helm_wait           = true
  mysql_compatibility = false

  values = jsonencode(lookup(local.values, "cadence", {}))
}

module "vault" {
  enabled   = lookup(lookup(local.values, "vault", {}), "enabled", "true")
  source    = "./modules/tf-vault"
  namespace = kubernetes_deployment.tiller.metadata[0].namespace

  database_driver   = local.defaultStorageBackend
  database_name     = "vault"
  database_username = "vault"
  database_password = random_string.vault-db-password.result
  database_host     = local.database.host
  database_port     = local.database.port

  ingress_enabled = lookup(lookup(local.values, "vault", {}), "ingress_enabled", "false")

  values = lookup(local.values, "vault", {})
}

module "dex" {
  source       = "./modules/tf-dex"
  release_name = "dex"
  namespace    = kubernetes_deployment.tiller.metadata[0].namespace

  issuer_url = "${local.scheme}://${local.externalHost}/dex"

  dex_client_id           = "pipeline"
  dex_client_redirect_uri = "${local.scheme}://${local.externalHost}/auth/dex/callback"

  storage_host     = local.database.host
  storage_port     = local.database.port
  storage_type     = local.defaultStorageBackend
  storage_database = "dex"
  storage_username = "dex"
  storage_password = random_string.dex-db-password.result
  storage_sslmode  = local.defaultStorageBackend == "postgres" ? "disable" : "false"

  static_email    = lookup(local.values, "email", "admin@example.com")
  static_username = lookup(local.values, "username", "admin")
  static_password = lookup(local.values, "password", random_string.pipeline-user-password.result)

  values = lookup(local.values, "dex", {})
}

module "traefik" {
  source                = "./modules/tf-traefik"
  namespace             = kubernetes_deployment.tiller.metadata[0].namespace
  release_name          = "traefik"
  ingress_class         = "traefik"
  kubernetes_namespaces = [kubernetes_deployment.tiller.metadata[0].namespace]
  service_type          = lookup(local.values, "ingressHostPort", false) ? "NodePort" : "LoadBalancer"
  ssl_enforced          = true
  default_cn            = lookup(local.values, "externalHost", "")
  hostport_enabled      = lookup(local.values, "ingressHostPort", "false")
  values                = jsonencode(lookup(local.values, "traefik", {}))
}

module "cicd" {
  source    = "./modules/tf-cicd"
  namespace = kubernetes_deployment.tiller.metadata[0].namespace

  enabled = lookup(lookup(local.values, "cicd", {}), "enabled", "false")

  fqdn = local.externalHost

  database_driver   = local.defaultStorageBackend
  database_name     = "cicd"
  database_username = "cicd"
  database_password = random_string.cicd-db-password.result
  database_host     = local.database.host
  database_port     = local.database.port
  tls_insecure      = local.tlsInsecure
  values            = lookup(local.values, "cicd", {})
}

module "anchore" {
  source    = "./modules/tf-anchore"
  namespace = kubernetes_deployment.tiller.metadata[0].namespace

  enabled = lookup(lookup(local.values, "anchore", {}), "enabled", "false")

  fqdn = local.externalHost

  database_name     = "anchore"
  database_username = "anchore"
  database_password = random_string.anchore-db-password.result
  database_host     = local.databaseInfo.postgres.host
  database_port     = local.databaseInfo.postgres.port

  admin_password = random_string.anchore-admin-password.result
  values         = lookup(local.values, "anchore", {})
}

module "ui" {
  source       = "./modules/tf-ui"
  namespace    = kubernetes_deployment.tiller.metadata[0].namespace
  release_name = "pipeline-ui"
  fqdn         = local.externalHost
  values       = lookup(local.values, "ui", {})
}

module "docs" {
  source       = "./modules/tf-docs"
  namespace    = kubernetes_deployment.tiller.metadata[0].namespace
  image_tag    = "0.13.7"
  release_name = "docs"
  values       = lookup(local.values, "docs", {})
  fqdn         = "${local.externalHost}"
}

module "pipeline" {
  source    = "./modules/tf-pipeline"
  namespace = kubernetes_deployment.tiller.metadata[0].namespace

  dex_url           = "${local.scheme}://${local.externalHost}/dex"
  dex_client_id     = "pipeline"
  dex_client_secret = module.dex.dex_client_secret
  dex_api_address   = module.dex.dex_api_address

  cp_scheme = local.scheme
  fqdn      = local.externalHost

  vault_address = module.vault.address

  host_aliases = [{ ip : module.traefik.cluster_ip, hostnames : [local.externalHost] }]

  database_driver   = local.defaultStorageBackend
  database_name     = "pipeline"
  database_username = "pipeline"
  database_password = random_string.pipeline-db-password.result
  database_host     = local.database.host
  database_port     = local.database.port

  cloudinfo_url = "${local.cloudinfoUrl}/api/v1"

  hollowtrees_url               = local.hasHollowtrees ? "${local.scheme}://${local.externalHost}/hollowtrees-alerts" : ""
  hollowtrees_token_signing_key = local.hasHollowtrees ? random_string.hollowtrees_tokensigningkey[0].result : ""

  tls_insecure = local.tlsInsecure

  cpu = var.default_cpu_request

  values = merge(
    { "configuration" : { "pipeline" : { "uuid" : lookup(local.values, "uuid", "") } } },
    lookup(local.values, "pipeline", {})
  )
}

module "hollowtrees" {
  source    = "./modules/tf-hollowtrees"
  namespace = kubernetes_deployment.tiller.metadata[0].namespace
  chart     = "hollowtrees-with-ps"

  enabled = local.hasHollowtrees

  telescopes_url    = "${local.telescopesUrl}/api/v1/recommender"
  tls_insecure      = local.tlsInsecure
  token_signing_key = local.hasHollowtrees ? random_string.hollowtrees_tokensigningkey[0].result : ""

  fqdn = local.externalHost

  values = lookup(local.values, "hollowtrees", {})
}

module "telescopes" {
  source    = "./modules/tf-telescopes"
  namespace = kubernetes_deployment.tiller.metadata[0].namespace
  enabled   = local.hasTelescopes

  cloudinfo_url = local.hasCloudinfo ? "http://cloudinfo-frontend/cloudinfo/api/v1/" : local.cloudinfoUrl

  values = lookup(local.values, "telescopes", {})
}

module "cloudinfo" {
  source       = "./modules/tf-cloudinfo"
  namespace    = kubernetes_deployment.tiller.metadata[0].namespace
  enabled      = local.hasCloudinfo
  vaultAddress = module.vault.address

  values = lookup(local.values, "cloudinfo", {})
}

module "ec2" {
  source  = "./provider/aws"
  enabled = local.provider == "ec2" ? true : false
  config  = local.providerConfig
}

resource "local_file" "ec2_host" {
  count      = local.provider == "ec2" ? 1 : 0
  filename   = "${var.workdir}/ec2-host"
  content    = module.ec2.host
  depends_on = [module.ec2]
}

resource "local_file" "ec2_private_key_pem" {
  count             = local.provider == "ec2" ? 1 : 0
  filename          = "${var.workdir}/id_rsa"
  sensitive_content = module.ec2.private_key_pem
  provisioner "local-exec" {
    command = "chmod 600 ${var.workdir}/id_rsa; chown $(stat -c %u ${var.workdir}) ${var.workdir}/id_rsa"
  }
  depends_on = [module.ec2]
}

resource "local_file" "k8s_traefik_address" {
  count    = (local.provider == "k8s" || local.provider == "custom") ? 1 : 0
  filename = "${var.workdir}/traefik-address"
  content  = module.traefik.url
}

resource "local_file" "external_address" {
  filename = "${var.workdir}/external-address"
  content  = "${local.scheme}://${local.externalHost}/"
}

data "local_file" "values" {
  filename = local.valuesFileName
}

module "custom" {
  source          = "./provider/custom"
  enabled         = local.provider == "custom" ? true : false
  config          = local.providerConfig
  kubeconfig_path = "${var.workdir}/kubeconfig"
}