locals {
  defaults = {
    chart_version = "0.4.0"
  }
}

variable "helm_wait" {
  default = false
}

variable "namespace" {
  default = "cadence"
}

variable "release_name" {
  default = "cadence"
}

variable "values" {
  default = "{}"
}

variable "persistence_driver" {
  default = "cassandra"
}

variable "install_cassandra" {
  default = true
}

variable "cassandra_hosts" {
  default = []
}

variable "cassandra_port" {
  default = 9042
}

variable "cassandra_cadence_keyspace" {
  default = "cadence"
}

variable "cassandra_cadence_visibility_keyspace" {
  default = "cadence_visibility"
}

variable "install_mysql" {
  default = false
}

variable "sql_driver" {
  default = "mysql"
}

variable "sql_host" {
  default = ""
}

variable "sql_port" {
  default = 3306
}

variable "sql_user" {
  default = ""
}

variable "sql_password" {
  default = ""
}

variable "sql_cadence_database" {
  default = "cadence"
}

variable "sql_cadence_visibility_database" {
  default = "cadence_visibility"
}

variable "mysql_compatibility" {
  default = "false"
}
