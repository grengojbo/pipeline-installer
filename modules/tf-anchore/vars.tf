variable "enabled" {
  default = "false"
}

variable "namespace" {
  default = "banzaicloud"
}

variable "release_name" {
  default = "anchore"
}

variable "fqdn" {
  default = ""
}

variable "admin_password" {
}

variable "admin_email" {
  default = "security@foo.bar"
}

variable "values" {
  default = {}
}

variable "database_name" {
  default = "anchore"
}

variable "database_username" {
  default = "anchoreengine"
}

variable "database_password" {
}

variable "database_host" {
  default = ""
}

variable "database_port" {
  default = "5432"
}
