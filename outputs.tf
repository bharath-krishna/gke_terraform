# output "instance_group_urls" {
#   value = google_container_cluster.primary.instance_group_urls[0]
# }

output "ingress_ip" {
  value = kubernetes_ingress.services.status.0.load_balancer.0.ingress.0.ip
}
