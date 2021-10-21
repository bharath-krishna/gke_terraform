resource "google_service_account" "default" {
  project      = var.project_name
  account_id   = var.service_account_id
  display_name = var.sa_display_name
}

resource "google_container_cluster" "primary" {
  project  = var.project_name
  name     = local.gke_cluster_name
  location = local.gcp_region

  remove_default_node_pool = true
  initial_node_count       = 1
}

resource "google_container_node_pool" "primary_preemptible_nodes" {
  project        = var.project_name
  name           = local.gke_node_pool_name
  location       = local.gcp_region
  cluster        = google_container_cluster.primary.name
  node_count     = 1
  node_locations = local.gcp_zones

  node_config {
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