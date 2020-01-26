variable "namespace" {
  default = "banzaicloud"
}

variable "enabled" {
  default = "false"
}

variable "release_name" {
  default = "telescopes"
}

variable "cloudinfo_url" {
  default = "https://beta.banzaicloud.io/cloudinfo/api/v1/"
}

variable "values" {
  default = "{}"
}
