# Prepare helm values for traefik
data "template_file" "traefik" {
  template = file("${path.module}/values/values.yaml")

  vars = {
    ingressClass                 = var.ingress_class
    namespace                    = var.namespace
    kubernetesNamespaces         = join(",", var.kubernetes_namespaces)
    accessLogsEnabled            = var.accesslogs_enabled
    accessLogsFormat             = var.accesslogs_format
    acmeEnabled                  = var.acme_enabled
    acmeEmail                    = var.acme_email
    acmePersistenceEnabled       = "true"
    acmePersistenceExistingClaim = "acme-pvc-${var.env}"
    defaultCert                  = base64encode(var.ssl_default_cert)
    defaultKey                   = base64encode(var.ssl_default_key)
    generateTLS                  = var.ssl_default_key != "" && var.ssl_default_cert != "" ? "false" : "true"
    defaultCN                    = var.default_cn
    loadBalancerIP               = var.load_balancer_ip
    serviceType                  = var.service_type
    sslEnforced                  = var.ssl_enforced
    hostPortEnabled              = var.hostport_enabled
  }
}

# Install traefik with helm
resource "helm_release" "traefik" {
  count   = "1"
  name    = var.release_name
  chart   = "stable/traefik"
  version = var.chart_version
  timeout = 9999
  wait    = true

  recreate_pods = var.service_type == "NodePort"

  namespace = var.namespace

  depends_on = [
    kubernetes_persistent_volume.acme-pv,
    kubernetes_persistent_volume_claim.acme-pvc,
  ]

  values = [
    data.template_file.traefik.rendered,
    var.values,
  ]
}

# Get traefik service ip or host
data "kubernetes_service" "traefik" {
  metadata {
    namespace = var.namespace
    name      = var.release_name
  }

  depends_on = [helm_release.traefik]
}

#
resource "kubernetes_persistent_volume" "acme-pv" {
  count = var.acme_enabled == "true" ? 1 : 0

  metadata {
    name = "acme-pv-${var.env}"

    labels = {
      persistentDisk = "acme"
    }
  }

  spec {
    capacity = {
      storage = "1Gi"
    }

    storage_class_name = "standard"
    access_modes       = ["ReadWriteOnce"]

    persistent_volume_source {
      gce_persistent_disk {
        pd_name = var.acme_storage_volume
        fs_type = "ext4"
      }
    }
  }
}

resource "kubernetes_persistent_volume_claim" "acme-pvc" {
  count = var.acme_enabled == "true" ? 1 : 0

  metadata {
    name = "acme-pvc-${var.env}"
  }

  spec {
    access_modes = ["ReadWriteOnce"]

    selector {
      match_labels = {
        persistentDisk = "acme"
      }
    }

    resources {
      requests = {
        storage = "1Gi"
      }
    }

    volume_name = kubernetes_persistent_volume.acme-pv[0].metadata[0].name
  }
}

