variable "namespace" {
  default = "banzaicloud"
}

variable "workdir" {
}

variable "db_password" {
}

variable "default_cpu_request" {
  default = "null"
}

variable "tiller_service_account" {
  type        = "string"
  default     = "tiller"
  description = "The Kubernetes service account to add to Tiller."
}

variable "tiller_replicas" {
  default     = 1
  description = "The amount of Tiller instances to run on the cluster."
}

variable "tiller_image" {
  type        = "string"
  default     = "gcr.io/kubernetes-helm/tiller"
  description = "The image used to install Tiller."
}

variable "tiller_version" {
  type        = "string"
  default     = "v2.14.3"
  description = "The Tiller image version to install."
}

variable "tiller_max_history" {
  default     = 0
  description = "Limit the maximum number of revisions saved per release. Use 0 for no limit."
}

variable "tiller_net_host" {
  default     = false
  description = "Install Tiller with net=host."
}

variable "tiller_node_selector" {
  type        = "map"
  default     = {}
  description = "Determine which nodes Tiller can land on."
}
