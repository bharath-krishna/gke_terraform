locals {
  gke_cluster_name     = "my-gke-terraform"
  gke_node_pool_name   = "my-terraform-node-pool"
  personal_hosted_zone = "bharathk.in"
  gcp_region           = "asia-northeast1"
  gcp_zones = [
    "asia-northeast1-a",
    # "asia-northeast1-b",
    # "asia-northeast1-c",
  ]
  gogin_target_port = 8088
  my_box_ui_port    = 3000
  my_box_api_port   = 8088
  keycloak_port     = 8080
}