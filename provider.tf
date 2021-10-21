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


resource "aws_route53_delegation_set" "main" {
  reference_name = "MyPersonalDelicationSet"
}

resource "aws_route53_zone" "primary" {
  name              = local.personal_hosted_zone
  delegation_set_id = aws_route53_delegation_set.main.id
  comment           = "Personal zone for hosting my sites"
}

data "aws_route53_delegation_set" "dset" {
  id = aws_route53_delegation_set.main.id
}

resource "null_resource" "create_aws_domain_name_servers" {
  provisioner "local-exec" {
    command = "/usr/local/bin/aws route53domains update-domain-nameservers --region us-east-1 --domain-name ${local.personal_hosted_zone} --nameservers Name=${join(" Name=", aws_route53_delegation_set.main.name_servers)}"
  }

  depends_on = [
    aws_route53_delegation_set.main
  ]
}
