data "helm_repository" "banzaicloud-stable" {
  name = "banzaicloud-stable"
  url  = "https://kubernetes-charts.banzaicloud.com/"
}

locals {
  is_sql       = var.persistence_driver == "sql" ? true : false
  is_cassandra = var.persistence_driver == "cassandra" ? true : false
  persistence_config = {
    sql       = local.is_sql ? data.template_file.persistence_sql[0].rendered : ""
    cassandra = local.is_cassandra ? data.template_file.persistence_cassandra[0].rendered : ""
  }
}

data "template_file" "cassandra" {
  count    = local.is_cassandra ? 1 : 0
  template = file("${path.module}/values/cassandra.yaml")
  vars = {
    install = var.install_cassandra
  }
}

data "template_file" "persistence_cassandra" {
  count    = local.is_cassandra ? 1 : 0
  template = file("${path.module}/values/persistence_cassandra.yaml")
  vars = {
    hosts                       = join(",", var.cassandra_hosts)
    port                        = var.cassandra_port
    cadence_keyspace            = var.cassandra_cadence_keyspace
    cadence_visibility_keyspace = var.cassandra_cadence_visibility_keyspace
  }
}

data "template_file" "mysql" {
  count    = local.is_sql ? 1 : 0
  template = file("${path.module}/values/mysql.yaml")
  vars = {
    install = var.install_mysql
  }
}

data "template_file" "mysql_compatibility" {
  count    = var.mysql_compatibility ? 1 : 0
  template = file("${path.module}/values/mysql_compatibility.yaml")
}

data "template_file" "persistence_sql" {
  count    = local.is_sql ? 1 : 0
  template = file("${path.module}/values/persistence_sql.yaml")
  vars = {
    driver                      = var.sql_driver
    host                        = var.sql_host
    port                        = var.sql_port
    user                        = var.sql_user
    password                    = var.sql_password
    cadence_database            = var.sql_cadence_database
    cadence_visibility_database = var.sql_cadence_visibility_database
  }
}

resource "helm_release" "cadence" {
  name       = var.release_name
  chart      = "cadence"
  repository = data.helm_repository.banzaicloud-stable.name
  version    = lookup(jsondecode(var.values), "chartVersion", local.defaults.chart_version)
  namespace  = var.namespace
  timeout    = lookup(jsondecode(var.values), "timeout", 300)
  wait       = lookup(jsondecode(var.values), "wait", var.helm_wait)

  values = [
    file("${path.module}/values/cadence.yaml"),
    var.mysql_compatibility ? data.template_file.mysql_compatibility[0].rendered : "",
    local.is_sql ? data.template_file.mysql[0].rendered : "",
    lookup(local.persistence_config, var.persistence_driver, ""),
    var.values
  ]
}
