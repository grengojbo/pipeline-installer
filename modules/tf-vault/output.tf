output "address" {
  value = "https://${helm_release.vault[0].metadata[0].name}:8200"
}

