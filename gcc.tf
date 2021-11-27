resource "google_service_account" "default" {
  project      = var.project_name
  account_id   = var.service_account_id
  display_name = var.sa_display_name
}

resource "google_container_cluster" "primary" {
  project        = var.project_name
  name           = local.gke_cluster_name
  location       = local.gcp_region
  node_locations = local.gcp_zones

  # Required when using google_container_node_pool
  # remove_default_node_pool = false
  initial_node_count = 1
  enable_autopilot   = true
  # Autopilot clusters require vertical pod autoscaler to be enabled.
  # Default is enabled. Declaring explicitly avoids updating on each apply
  vertical_pod_autoscaling {
    enabled = true
  }
}
