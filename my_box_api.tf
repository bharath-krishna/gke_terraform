resource "kubernetes_deployment" "my_box_api" {
  metadata {
    name = "my-box-api"
    labels = {
      app = "my-box-api"
    }
  }

  spec {
    replicas = var.profile_enabled ? 1 : 0

    selector {
      match_labels = {
        app = "my-box-api"
      }
    }

    template {
      metadata {
        labels = {
          app = "my-box-api"
        }
      }

      spec {
        automount_service_account_token = false
        enable_service_links            = false
        container {
          image = "krishbharath/my_box_api"
          name  = "my-box-api"

          env {
            name = "API_FIREBASE_CONFIGS"
            value_from {
              config_map_key_ref {
                key      = "API_FIREBASE_CONFIGS"
                name     = "my-box-api-config-map"
                optional = false
              }
            }
          }

          env {
            name = "ORIGINS"
            value_from {
              config_map_key_ref {
                key      = "ORIGINS"
                name     = "my-box-api-config-map"
                optional = false
              }
            }
          }

          #   resources {
          #     limits = {
          #       cpu    = "200m"
          #       memory = "256Mi"
          #     }
          #     requests = {
          #       cpu    = "100m"
          #       memory = "126Mi"
          #     }
          #   }

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
              path = "/apidocs"
              port = local.my_box_api_port

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
    google_container_cluster.primary,
    google_container_node_pool.primary_preemptible_nodes
  ]
}

resource "kubernetes_config_map" "my_box_api_config_map" {
  metadata {
    name = "my-box-api-config-map"
  }

  data = {
    API_FIREBASE_CONFIGS = var.api_firebase_configs
    ORIGINS              = var.box_api_origins
  }
}

resource "kubernetes_service" "my_box_api" {
  metadata {
    name = "my-box-api-service"
    labels = {
      "app" = "my-box-api"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment.my_box_api.metadata.0.labels.app
    }
    port {
      port        = local.my_box_api_port
      target_port = local.my_box_api_port
    }

    type = "NodePort"
  }
  depends_on = [
    kubernetes_deployment.my_box_api
  ]
}
