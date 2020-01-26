variable "enabled" {
  default = "false"
}

variable "namespace" {
  default = "banzaicloud"
}

variable "release_name" {
  default = "cicd"
}

variable "fqdn" {
  default = ""
}

variable "values" {
  default = ""
}

variable "database_driver" {
  default = "postgres"
}

variable "database_name" {
  default = "cicd"
}

variable "database_username" {
  default = "cicd"
}

variable "database_password" {
  default = ""
}

variable "database_host" {
  default = ""
}

variable "database_port" {
  default = "5432"
}

variable "tls_insecure" {
  default = "false"
}

