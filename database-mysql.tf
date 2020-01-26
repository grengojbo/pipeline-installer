module "mysql" {
  source    = "./modules/tf-mysql"
  namespace = kubernetes_deployment.tiller.metadata[0].namespace
  enabled   = lookup(lookup(local.values, "mysql", {}), "enabled", "true")

  initializationFiles = map(
    "cadence.sql", data.template_file.cadence-mysql.rendered,
    "cicd.sql", data.template_file.cicd-mysql.rendered,
    "dex.sql", data.template_file.dex-mysql.rendered,
    "pipeline.sql", data.template_file.pipeline-mysql.rendered,
    "vault.sql", data.template_file.vault-mysql.rendered
  )
  values = lookup(local.values, "mysql", {})
}