variable "namespace" {
  default = "default"
}

variable "release_name" {
}

variable "enabled" {
  default = true
}

variable "values" {
  default = "{}"
}

variable "image_tag" {
  default = "latest"
}

variable "image_pull_policy" {
  default = "Always"
}

variable "fqdn" {
  default = ""
}

variable "keel_notify" {
  default = ""
}

variable "keel_policy" {
  default = ""
}

variable "keel_trigger" {
  default = ""
}

variable "keel_approvals" {
  default = ""
}

