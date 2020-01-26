output "dex_client_secret" {
  value     = random_string.dex_client_secret.result
  sensitive = true
}

output "dex_api_address" {
  value = "${helm_release.dex.metadata[0].name}:5557"
}

