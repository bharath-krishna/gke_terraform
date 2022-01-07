resource "kubernetes_deployment" "gogin_framework" {
  metadata {
    name = "gogin-framework"
    labels = {
      app = "gogin-framework"
    }
  }

  spec {
    replicas = var.profile_enabled ? 1 : 0

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
          port {
            container_port = local.gogin_target_port
          }

          readiness_probe {
            http_get {
              path = "/swagger/index.html"
              port = local.gogin_target_port
              scheme = "HTTP"

              http_header {
                name  = "X-Custom-Header"
                value = "HealthCheck"
              }
            }

            initial_delay_seconds = 15
            period_seconds = 15
            failure_threshold = 5
            success_threshold = 2
          }

          liveness_probe {
            http_get {
              path = "/swagger/index.html"
              port = local.gogin_target_port
              scheme = "HTTP"

              http_header {
                name  = "X-Custom-Header"
                value = "HealthCheck"
              }
            }

            initial_delay_seconds = 15
            period_seconds = 15
            failure_threshold = 5
            success_threshold = 1
            timeout_seconds = 5
          }
        }
      }
    }
  }
  depends_on = [
    google_container_cluster.primary
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
