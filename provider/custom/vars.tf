variable "enabled" {
  default = false
  type    = bool
}

variable "config" {
  default = {}
}

variable "tags" {
  default = {}
}

variable "kubeconfig_path" {
  default = ""
}
