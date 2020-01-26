variable "release_name" {
  default = "dex"
}

variable "namespace" {
  default = "dex"
}

variable "static_email" {
  default = "admin@example.com"
}

variable "static_username" {
  default = "admin"
}

variable "static_password" {
  default = ""
}

variable "github_client_id" {
  default = ""
}

variable "github_client_secret" {
  default = ""
}

variable "dex_client_id" {
}

variable "dex_client_redirect_uri" {
  // default = "http://localhost/auth/dex/callback"
}

variable "ingress_class" {
  default = "traefik"
}

variable "issuer_url" {
  // default = "http://localhost/dex"
}

variable "storage_type" {
  default = "postgres"
}

variable "storage_host" {
}

variable "storage_port" {
  default = "5432"
}

variable "storage_database" {
  default = "dex"
}

variable "storage_username" {
  default = "dex"
}

variable "storage_password" {
}

variable "storage_sslmode" {
  default = "disable"
}

variable "values" {
  default = ""
}
