variable "namespace" {
  default = "vault"
}

variable "release_name" {
  default = "vault"
}

variable "values" {
  default = ""
}

variable "database_driver" {
  default = "postgres"
}

variable "database_name" {
  default = "vault"
}

variable "database_username" {
  default = "vault"
}

variable "database_password" {
}

variable "database_host" {
  default = "postgresql-postgresql"
}

variable "database_port" {
  default = "5432"
}

variable "enabled" {
  default = true
}

variable "ingress_enabled" {
  default = false
}
