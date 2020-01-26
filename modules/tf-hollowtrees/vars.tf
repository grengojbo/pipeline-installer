variable "namespace" {
  default = "banzaicloud"
}

variable "enabled" {
  default = "false"
}

variable "release_name" {
  default = "hollowtrees"
}

variable "chart" {
  default = "hollowtrees"
}

variable "tls_insecure" {
  default = "false"
}

variable "fqdn" {
  default = ""
}

variable "values" {
  default = "{}"
}

variable "token_signing_key" {
  default = ""
}

variable "pipeline_url" {
  default = "http://pipeline-internal:9091/pipeline/api/v1"
}

variable "telescopes_url" {
  default = "https://beta.banzaicloud.io/recommender/api/v1/recommender"
}