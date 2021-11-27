data "google_client_config" "provider" {}

provider "kubernetes" {
  host  = "https://${google_container_cluster.primary.endpoint}"
  token = data.google_client_config.provider.access_token
  cluster_ca_certificate = base64decode(
    google_container_cluster.primary.master_auth[0].cluster_ca_certificate,
  )
}

provider "aws" {
  region     = "us-west-2"
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
}
