output "host" {
  value = var.enabled ? (aws_instance.pipeline[0].public_dns != "" ? aws_instance.pipeline[0].public_dns : (aws_instance.pipeline[0].public_ip != "" ? aws_instance.pipeline[0].public_ip : aws_instance.pipeline[0].private_ip)) : ""
}

output "private_key_pem" {
  value     = var.enabled ? tls_private_key.pipeline[0].private_key_pem : ""
  sensitive = true
}