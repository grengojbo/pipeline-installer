output "username" {
  sensitive = false
  value     = local.anchoreEmail != "" ? local.anchoreEmail : var.admin_email
}

output "password" {
  sensitive = true
  value     = local.anchorePassword != "" ? local.anchorePassword : var.admin_password
}
