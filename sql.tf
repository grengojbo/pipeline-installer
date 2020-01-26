data "template_file" "anchore-postgres" {
  template = "${file("${path.module}/sql/postgres/anchore.sql")}"

  vars = {
    password = "${random_string.anchore-db-password.result}"
  }
}

data "template_file" "cicd-postgres" {
  template = "${file("${path.module}/sql/postgres/cicd.sql")}"

  vars = {
    password = "${random_string.cicd-db-password.result}"
  }
}

data "template_file" "dex-postgres" {
  template = "${file("${path.module}/sql/postgres/dex.sql")}"

  vars = {
    password = "${random_string.dex-db-password.result}"
  }
}

data "template_file" "pipeline-postgres" {
  template = "${file("${path.module}/sql/postgres/pipeline.sql")}"

  vars = {
    password = "${random_string.pipeline-db-password.result}"
  }
}

data "template_file" "vault-postgres" {
  template = "${file("${path.module}/sql/postgres/vault.sql")}"

  vars = {
    password = "${random_string.vault-db-password.result}"
  }
}

data "template_file" "cadence-mysql" {
  template = "${file("${path.module}/sql/mysql/cadence.sql")}"

  vars = {
    password = "${random_string.cadence-db-password.result}"
  }
}

data "template_file" "cicd-mysql" {
  template = "${file("${path.module}/sql/mysql/cicd.sql")}"

  vars = {
    password = "${random_string.cicd-db-password.result}"
  }
}

data "template_file" "dex-mysql" {
  template = "${file("${path.module}/sql/mysql/dex.sql")}"

  vars = {
    password = "${random_string.dex-db-password.result}"
  }
}

data "template_file" "pipeline-mysql" {
  template = "${file("${path.module}/sql/mysql/pipeline.sql")}"

  vars = {
    password = "${random_string.pipeline-db-password.result}"
  }
}

data "template_file" "vault-mysql" {
  template = "${file("${path.module}/sql/mysql/vault.sql")}"

  vars = {
    password = "${random_string.vault-db-password.result}"
  }
}