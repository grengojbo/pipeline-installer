variable "namespace" {
  default = "banzaicloud"
}

variable "release_name" {
  default = "pipeline"
}

variable "values" {
  default = ""
}

variable "cp_scheme" {
  default = "https"
}

variable "fqdn" {
}

variable "image_tag" {
  default = "0.34.0"
}

variable "database_driver" {
  default = "postgres"
}

variable "database_name" {
  default = "pipeline"
}

variable "database_username" {
  default = "pipeline"
}

variable "database_password" {
}

variable "database_host" {
  default = "postgresql-postgresql.banzaicloud"
}

variable "database_port" {
  default = "5432"
}

variable "dex_url" {
}

variable "dex_client_id" {
  default = "pipeline"
}

variable "dex_client_secret" {
}

variable "vault_address" {
  default = "https://vault:8200"
}

variable "dex_api_address" {
}

variable "tls_insecure" {
  default = "false"
}

variable "cloudinfo_url" {
}

variable "hollowtrees_url" {
  default = ""
}

variable "hollowtrees_token_signing_key" {
  default = ""
}

variable "host_aliases" {
  default = []
}

variable "cpu" {
  default = "null"
}

