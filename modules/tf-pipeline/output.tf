output "host" {
  value = "${helm_release.pipeline.name}.${var.namespace}"
}
