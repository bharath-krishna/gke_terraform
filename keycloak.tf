resource "kubernetes_deployment" "keycloak" {
  metadata {
    name = "keycloak"
    labels = {
      app = "keycloak"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "keycloak"
      }
    }

    template {
      metadata {
        labels = {
          app = "keycloak"
        }
      }

      spec {
        image_pull_secrets {
          name = "docker-creds"
        }
        automount_service_account_token = false
        enable_service_links            = false
        container {
          image = "krishbharath/keycloak_backup"
          name  = "keycloak"

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

          readiness_probe {
            http_get {
              path   = "/auth/realms/master"
              port   = local.keycloak_port
              scheme = "HTTP"
            }

            initial_delay_seconds = 90
            period_seconds        = 30
            failure_threshold     = 3
            success_threshold     = 1
            timeout_seconds       = 5
          }

          liveness_probe {
            http_get {
              path   = "/auth/realms/master"
              port   = local.keycloak_port
              scheme = "HTTP"
            }

            initial_delay_seconds = 90
            period_seconds        = 30
            failure_threshold     = 3
            success_threshold     = 1
            timeout_seconds       = 5
          }

          port {
            container_port = local.keycloak_port
          }
        }
      }
    }
  }
  depends_on = [
    google_container_cluster.primary,
    google_container_node_pool.primary_preemptible_nodes,
    kubernetes_secret.docker_creds
  ]
}

resource "kubernetes_service" "keycloak" {
  metadata {
    name = "keycloak"
    labels = {
      "app" = "keycloak"
    }
  }
  spec {
    selector = {
      app = kubernetes_deployment.keycloak.metadata.0.labels.app
    }
    port {
      port        = local.keycloak_port
      target_port = local.keycloak_port
    }

    type = "NodePort"
  }
  depends_on = [
    kubernetes_deployment.keycloak
  ]
}


# resource "kubernetes_secret" "docker_creds" {
#   type = "docker_server"
#   metadata {
#     name = "docker-creds"
#     labels = {
#       app = "keycloak"
#     }
#   }
#   data = {
#     "docker_server" = "docker.io"
#     "docker_username" = var.docker_username
#     "docker_password" = var.docker_password
#     "docker_email" = var.docker_email
#   }
# }

resource "kubernetes_secret" "docker_creds" {
  metadata {
    name = "docker-creds"
  }

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.docker_server}" = {
          auth = "${base64encode("${var.docker_username}:${var.docker_password}")}"
        }
      }
    })
  }

  type = "kubernetes.io/dockerconfigjson"
}