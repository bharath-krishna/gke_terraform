# Autopolot cluster mailnly used for production, low cost clusters
# resource "google_service_account" "default" {
#   project      = var.project_name
#   account_id   = var.service_account_id
#   display_name = var.sa_display_name
# }

# resource "google_container_cluster" "primary" {
#   project        = var.project_name
#   name           = local.gke_cluster_name
#   location       = local.gcp_region
#   node_locations = local.gcp_zones

#   # Required when using google_container_node_pool
#   # remove_default_node_pool = false
#   initial_node_count = 1
#   enable_autopilot   = true
#   # Autopilot clusters require vertical pod autoscaler to be enabled.
#   # Default is enabled. Declaring explicitly avoids updating on each apply
#   vertical_pod_autoscaling {
#     enabled = true
#   }
# }


# Zonal (Non Autopilot) cluster used for testing, faster resource creation.
resource "google_service_account" "default" {
  project      = var.project_name
  account_id   = var.service_account_id
  display_name = var.sa_display_name
}

resource "google_container_cluster" "primary" {
  project  = var.project_name
  name     = local.gke_cluster_name
  location = local.gcp_region

  # We can't create a cluster with no node pool defined, but we want to only use
  # separately managed node pools. So we create the smallest possible default
  # node pool and immediately delete it.
  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  project        = var.project_name
  name           = local.gke_node_pool_name
  location       = local.gcp_region
  cluster        = google_container_cluster.primary.name
  node_count     = 3
  node_locations = local.gcp_zones

  node_config {
    disk_size_gb = 100
    disk_type    = "pd-standard"
    labels       = {}
    preemptible  = true
    machine_type = "e2-medium"

    service_account = google_service_account.default.email
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform"
    ]
  }

  depends_on = [
    google_container_cluster.primary
  ]
}