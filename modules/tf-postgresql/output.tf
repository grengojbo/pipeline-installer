output "host" {
  value = "${var.release_name}.${var.namespace}"
}

output "port" {
  value = "5432"
}