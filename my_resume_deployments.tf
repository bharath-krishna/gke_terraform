resource "kubernetes_deployment" "my_resume" {
  metadata {
    name = "my-resume"
    labels = {
      app = "my-resume"
    }
  }

  spec {
    replicas = var.profile_enabled ? 1 : 0

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
          image = "krishbharath/my_resume"
          name  = "my-resume"

          # resources block not required in autopilot mode.
          # Pods are virtically auto scaled
          # resources {
          #   limits = {
          #     cpu    = "200"
          #     memory = "200Mi"
          #   }
          #   requests = {
          #     cpu    = "100m"
          #     memory = "50Mi"
          #   }
          # }

          security_context {
            allow_privilege_escalation = false
            privileged                 = false
            read_only_root_filesystem  = false
            run_as_non_root            = false

            capabilities {
              add = []
              drop = [
                "NET_RAW",
              ]
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
    google_container_cluster.primary
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

