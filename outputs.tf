output "instance_group_urls" {
  value = google_container_cluster.primary.instance_group_urls[0]
}

output "ingress_ip" {
  value = kubernetes_ingress.services.status.0.load_balancer.0.ingress.0.ip
}

output "delication_set_name_servers" {
  value = aws_route53_delegation_set.main.name_servers
}

output "Update_Name_Server" {
  value = "Please Node: If you have created new deligation set and added same to hosted zone its necessory to update registered domain's name servers list from UI as there is terraform resource for doing it as of now."

}
