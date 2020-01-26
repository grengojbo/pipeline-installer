output "host" {
  value = var.enabled == "true" ? "mysql.${var.namespace}" : ""
}

output "port" {
  value = "3306"
}
