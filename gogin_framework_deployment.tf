resource "kubernetes_deployment" "gogin_framework" {
  metadata {
    name = "gogin-framework"
    labels = {
      app = "gogin-framework"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "gogin-framework"
      }
    }

    template {
      metadata {
        labels = {
          app = "gogin-framework"
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false
        container {
          image = "krishbharath/gogin-framework"
          name  = "gogin-framework"

          env {
            name = "GOGIN_ADDRESS"
            value_from {
              config_map_key_ref {
                key      = "GOGIN_ADDRESS"
                name     = "my-services-config-map"
                optional = false
              }
            }
          }

          resources {
            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
            requests = {
              cpu    = "100m"
              memory = "100Mi"
            }
          }

          liveness_probe {
            http_get {
              path = "/swagger/index.html"
              port = local.gogin_target_port

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

resource "kubernetes_config_map" "my_services_config_map" {
  metadata {
    name = "my-services-config-map"
  }

  data = {
    GOGIN_ADDRESS = "0.0.0.0:${local.gogin_target_port}"
  }
}

resource "kubernetes_service" "gogin_framework" {
  metadata {
    name = "gogin-framework-service"
    labels = {
      "app" = "gogin-framework"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment.gogin_framework.metadata.0.labels.app
    }
    port {
      port        = local.gogin_target_port
      target_port = local.gogin_target_port
    }

    type = "NodePort"
  }
  depends_on = [
    kubernetes_deployment.gogin_framework
  ]
}
