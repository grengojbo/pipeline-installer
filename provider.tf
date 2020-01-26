provider "template" {
  version = "~> 2.1"
}

provider "random" {
  version = "~> 2.2"
}

provider "helm" {
  version         = "~> 0.10.4"
  install_tiller  = false
  service_account = kubernetes_service_account.tiller.metadata[0].name
  namespace       = kubernetes_namespace.namespace.id
  home            = "${var.workdir}/.helm"
}

provider "kubernetes" {
  version = "~> 1.9"
}

provider "local" {
  version = "~> 1.4"
}