locals {
  load_balancer_ips = coalescelist(
    data.kubernetes_service.traefik.load_balancer_ingress,
    [
      {
        "ip" = "N/A"
      },
    ],
  )
}

// Return the loadbalancer ip or hostname or manually provided externalIP if any
output "url" {
  value = var.service_type == "LoadBalancer" ? element(compact(values(local.load_balancer_ips[0])), 0) : element(
    concat(
      tolist(data.kubernetes_service.traefik.spec[0].external_ips),
      [""],
    ),
    0,
  )
}

output "cluster_ip" {
  value = data.kubernetes_service.traefik.spec[0].cluster_ip
}

