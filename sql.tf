
resource "local_file" "postgres_anchore_sql" {
  count = 1
  content = templatefile("${path.module}/sql/postgres/anchore.sql", {
    password = random_string.anchore-db-password.result
    }
  )
  filename = "${path.module}/tmp/anchore.sql"
}

resource "local_file" "postgres_cicd_sql" {
  count = 1
  content = templatefile("${path.module}/sql/postgres/cicd.sql", {
    password = random_string.cicd-db-password.result
    }
  )
  filename = "${path.module}/tmp/cicd.sql"
}

resource "local_file" "postgres_dex_sql" {
  count = 1
  content = templatefile("${path.module}/sql/postgres/dex.sql", {
    password = random_string.dex-db-password.result
    }
  )
  filename = "${path.module}/tmp/dex.sql"
}

resource "local_file" "postgres_pipeline_sql" {
  count = 1
  content = templatefile("${path.module}/sql/postgres/pipeline.sql", {
    password = random_string.pipeline-db-password.result
    }
  )
  filename = "${path.module}/tmp/pipeline.sql"
}

resource "local_file" "postgres_vault_sql" {
  count = 1
  content = templatefile("${path.module}/sql/postgres/vault.sql", {
    password = random_string.vault-db-password.result
    }
  )
  filename = "${path.module}/tmp/vault.sql"
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
    password = random_string.vault-db-password.result
  }
}

resource "null_resource" "db_init_anchore" {
  count   = local.externalDatabase ? 1 : 0
  provisioner "local-exec" {
    command = "psql -h ${local.rootDatabaseHost} -U ${local.rootDatabaseUser} -f ${path.module}/tmp/anchore.sql"
    environment = {
      PGPASSWORD = local.rootDatabasePassword
    }
  }
  depends_on = [local_file.postgres_anchore_sql]
}

resource "null_resource" "db_init_cicd" {
  count   = local.externalDatabase ? 1 : 0
  provisioner "local-exec" {
    command = "psql -h ${local.rootDatabaseHost} -U ${local.rootDatabaseUser} -f ${path.module}/tmp/cicd.sql"
    environment = {
      PGPASSWORD = local.rootDatabasePassword
    }
  }
  depends_on = [local_file.postgres_cicd_sql]
}

resource "null_resource" "db_init_dex" {
  count   = local.externalDatabase ? 1 : 0
  provisioner "local-exec" {
    command = "psql -h ${local.rootDatabaseHost} -U ${local.rootDatabaseUser} -f ${path.module}/tmp/dex.sql"
    environment = {
      PGPASSWORD = local.rootDatabasePassword
    }
  }
  depends_on = [local_file.postgres_dex_sql]
}

resource "null_resource" "db_init_pipeline" {
  count   = local.externalDatabase ? 1 : 0
  
  provisioner "local-exec" {
    command = "psql -h ${local.rootDatabaseHost} -U ${local.rootDatabaseUser} -f ${path.module}/tmp/pipeline.sql"
    environment = {
      PGPASSWORD = local.rootDatabasePassword
    }
  }
  
  provisioner "local-exec" {
    when    = "destroy"
    command = "psql -h ${local.rootDatabaseHost} -U ${local.rootDatabaseUser} -f ${path.module}/sql/postgres/drop.sql"
    environment = {
      PGPASSWORD = local.rootDatabasePassword
    }
  }
  
  depends_on = [local_file.postgres_pipeline_sql]
}

resource "null_resource" "db_init_vault" {
  count   = local.externalDatabase ? 1 : 0
  provisioner "local-exec" {
    command = "psql -h ${local.rootDatabaseHost} -U ${local.rootDatabaseUser} -f ${path.module}/tmp/vault.sql"
    environment = {
      PGPASSWORD = local.rootDatabasePassword
    }
  }
  depends_on = [local_file.postgres_vault_sql]
}
