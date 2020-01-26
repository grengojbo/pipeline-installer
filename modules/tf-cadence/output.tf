locals {
  chartName       = lookup(jsondecode(var.values), "nameOverride", "cadence")
  containsCadence = replace(helm_release.cadence.name, local.chartName, "") != helm_release.cadence.name
  releaseName     = local.containsCadence ? helm_release.cadence.name : "${helm_release.cadence.name}-${local.chartName}"
  fullName        = substr(lookup(jsondecode(var.values), "fullNameOverride", local.releaseName), 0, 63)
}

output "host" {
  value = "${substr(local.fullName, 0, 54)}-frontend.${var.namespace}"
}
