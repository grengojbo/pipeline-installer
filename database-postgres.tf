module "postgresql" {
  source    = "./modules/tf-postgresql"
  namespace = kubernetes_deployment.tiller.metadata[0].namespace
  enabled   = local.defaultStorageBackend == "postgres" ? "true" : "false"

  initScripts = map(
    "anchore.sql", data.template_file.anchore-postgres.rendered,
    "cicd.sql", data.template_file.cicd-postgres.rendered,
    "dex.sql", data.template_file.dex-postgres.rendered,
    "pipeline.sql", data.template_file.pipeline-postgres.rendered,
    "vault.sql", data.template_file.vault-postgres.rendered
  )
  values = lookup(local.values, "postgresql", {})
}
