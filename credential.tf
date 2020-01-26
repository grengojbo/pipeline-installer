resource "random_string" "anchore-admin-password" {
  length  = 32
  special = false
}

resource "random_string" "anchore-db-password" {
  length  = 32
  special = false
}

resource "random_string" "cadence-db-password" {
  length  = 32
  special = false
}

resource "random_string" "dex-db-password" {
  length  = 32
  special = false
}

resource "random_string" "cicd-db-password" {
  length  = 32
  special = false
}

resource "random_string" "pipeline-db-password" {
  length  = 32
  special = false
}

resource "random_string" "vault-db-password" {
  length  = 32
  special = false
}

# Hollowtrees with pipeline scaler plugin
resource "random_string" "hollowtrees_tokensigningkey" {
  count   = local.hasHollowtrees ? 1 : 0
  length  = 32
  special = false
}

resource "random_string" "pipeline-user-password" {
  length  = 16
  special = false
}