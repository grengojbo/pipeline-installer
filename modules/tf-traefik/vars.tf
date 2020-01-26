variable "env" {
  default = "default"
}

variable "accesslogs_enabled" {
  default = "false"
}

variable "accesslogs_format" {
  default = "common"
}

variable "acme_enabled" {
  default = "false"
}

variable "acme_storage_volume" {
  default = ""
}

variable "acme_challenge_type" {
  default = "tls-alpn-01"
}

variable "acme_staging" {
  default = "true"
}

variable "acme_email" {
  default = "admin@example.com"
}

variable "namespace" {
  default = "default"
}

variable "ingress_class" {
  default = ""
}

variable "ssl_default_cert" {
  default = ""
}

variable "ssl_default_key" {
  default = ""
}

variable "load_balancer_ip" {
  default = ""
}

variable "kubernetes_namespaces" {
  type    = list(string)
  default = []
}

variable "chart_version" {
  default = "1.77.3"
}

variable "release_name" {
}

variable "service_type" {
  default = "LoadBalancer"
}

variable "ssl_enforced" {
  default = true
}

variable "hostport_enabled" {
  default = false
}

variable "values" {
  default = ""
}

variable "default_cn" {
  default = ""
}

