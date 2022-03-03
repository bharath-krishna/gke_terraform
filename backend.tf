terraform {
  backend "gcs" {
    bucket  = "gke-terraform-states"
    credentials = "/Users/bharath.krishna/Downloads/bionic-limiter-335-ff5d784011e1.json"
  }
}