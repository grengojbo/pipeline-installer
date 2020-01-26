// This resource is now deprecated and will be removed!
//
// There is no guarantee, that the CLI will call this in the future at all,
// so this is here only for backward compatibility reasons.
//
// If the CLI generates merged values on its own with the name `generated-values-cli.yaml`,
// the `generated-values.yaml` created by this resource is ignored, see `main.tf`.
resource "null_resource" "preapply_hook" {
  triggers = {
    defaults  = fileexists("${path.module}/values.yaml") ? filesha1("${path.module}/values.yaml") : ""
    overrides = filesha1("${var.workdir}/values.yaml")
    generated = fileexists("${var.workdir}/generated-values.yaml") ? filesha1("${var.workdir}/generated-values.yaml") : ""
  }
  provisioner "local-exec" {
    command = <<-EOT
      if [ -f ${path.module}/values.yaml ]; then
        yami ${path.module}/values.yaml ${var.workdir}/values.yaml > ${var.workdir}/generated-values.yaml
      else
        rm -f ${var.workdir}/generated-values.yaml
      fi
    EOT
  }
}