resource "kubernetes_deployment" "my_resume" {
  metadata {
    name = "my-resume"
    labels = {
      app = "my-resume"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "my-resume"
      }
    }

    template {
      metadata {
        labels = {
          app = "my-resume"
        }
      }

      spec {
        container {
          image = "krishbharath/my_resume:v2021"
          name  = "my-resume"

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/"
              port = 80

              http_header {
                name  = "X-Custom-Header"
                value = "Awesome"
              }
            }

            initial_delay_seconds = 3
            period_seconds        = 3
          }
        }
      }
    }
  }

  depends_on = [
    google_container_node_pool.primary_preemptible_nodes
  ]
}

resource "kubernetes_service" "my_resume" {
  metadata {
    name = "my-resume-service"
  }
  spec {
    selector = {
      app = kubernetes_deployment.my_resume.metadata.0.labels.app
    }
    session_affinity = "ClientIP"
    port {
      port        = 80
      target_port = 80
    }

    type = "NodePort"
  }

  depends_on = [
    kubernetes_deployment.my_resume
  ]
}

