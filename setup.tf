resource "kubernetes_service_account" "tiller" {
  metadata {
    name      = "${kubernetes_namespace.namespace.id}-tiller"
    namespace = kubernetes_namespace.namespace.id

    labels = {
      creator = "cp-installer"
    }
  }
}

resource "kubernetes_cluster_role_binding" "tiller" {
  count = 1

  metadata {
    name = "${kubernetes_namespace.namespace.id}-tiller"

    labels = {
      creator = "cp-installer"
    }
  }

  subject {
    kind = "User"
    name = "system:serviceaccount:${kubernetes_namespace.namespace.id}:${kubernetes_service_account.tiller.metadata[0].name}"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }
}

resource "kubernetes_namespace" "namespace" {
  metadata {
    name = var.namespace
  }
  depends_on = [
    module.custom,
  ]
}

resource "kubernetes_deployment" "tiller" {

  metadata {
    name      = "tiller-deploy"
    namespace = kubernetes_namespace.namespace.id

    labels = {
      app  = "helm"
      name = "tiller"
    }
  }

  spec {
    replicas = var.tiller_replicas

    selector {
      match_labels = {
        app  = "helm"
        name = "tiller"
      }
    }

    template {
      metadata {
        labels = {
          app  = "helm"
          name = "tiller"
        }
      }

      spec {
        service_account_name = kubernetes_service_account.tiller.metadata[0].name

        container {
          name              = "tiller"
          image             = "${var.tiller_image}:${var.tiller_version}"
          image_pull_policy = "IfNotPresent"

          port {
            name           = "tiller"
            container_port = 44134
          }

          port {
            name           = "http"
            container_port = 44135
          }

          env {
            name  = "TILLER_NAMESPACE"
            value = kubernetes_namespace.namespace.id
          }

          env {
            name  = "TILLER_HISTORY_MAX"
            value = var.tiller_max_history
          }

          liveness_probe {
            http_get {
              path = "/liveness"
              port = 44135
            }

            initial_delay_seconds = 1
            timeout_seconds       = 1
          }

          readiness_probe {
            http_get {
              path = "/readiness"
              port = 44135
            }

            initial_delay_seconds = 1
            timeout_seconds       = 1
          }
        }
        host_network                    = var.tiller_net_host
        node_selector                   = var.tiller_node_selector
        automount_service_account_token = true
      }
    }
  }
  depends_on = [
    kubernetes_cluster_role_binding.tiller,
  ]
}