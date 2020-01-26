output "pipeline-username" {
  value = lookup(local.values, "email", "admin@example.com")
}

output "pipeline-password" {
  value = lookup(local.values, "password", random_string.pipeline-user-password.result)
}

output "pipeline-address" {
  value = "${local.scheme}://${local.externalHost}/"
}