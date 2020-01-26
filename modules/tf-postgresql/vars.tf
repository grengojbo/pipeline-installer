variable "enabled" {
  default = "false"
}

variable "namespace" {
  default = "banzaicloud"
}

variable "release_name" {
  default = "postgresql"
}

variable "username" {
  default = "postgres"
}

variable "database" {
  default = ""
}

variable "values" {
  default = {}
}

variable "initScripts" {
  type    = map(string)
  default = {}
}

