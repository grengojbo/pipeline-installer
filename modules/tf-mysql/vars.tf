variable "namespace" {
  default = "banzaicloud"
}

variable "release_name" {
  default = "mysql"
}

variable "values" {
  default = "{}"
}

variable "enabled" {
  default = "true"
}

variable "initializationFiles" {
  type    = map(string)
  default = {}
}
