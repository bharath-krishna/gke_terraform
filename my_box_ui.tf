# resource "kubernetes_deployment" "my_box_ui" {
#   metadata {
#     name = "my-box-ui"
#     labels = {
#       app = "my-box-ui"
#     }
#   }

#   spec {
#     replicas = var.profile_enabled ? 1 : 0

#     selector {
#       match_labels = {
#         app = "my-box-ui"
#       }
#     }

#     template {
#       metadata {
#         labels = {
#           app = "my-box-ui"
#         }
#       }

#       spec {
#         automount_service_account_token = false
#         enable_service_links            = false
#         container {
#           image = "krishbharath/my_box_ui"
#           name  = "my-box-ui"

#           env {
#             name = "NEXT_PUBLIC_API_HOST"
#             value_from {
#               config_map_key_ref {
#                 key      = "NEXT_PUBLIC_API_HOST"
#                 name     = "my-box-ui-config-map"
#                 optional = false
#               }
#             }
#           }

#           env {
#             name = "FIREBASE_CLIENT_EMAIL"
#             value_from {
#               config_map_key_ref {
#                 key      = "FIREBASE_CLIENT_EMAIL"
#                 name     = "my-box-ui-config-map"
#                 optional = false
#               }
#             }
#           }

#           env {
#             name = "NEXT_PUBLIC_FIREBASE_PUBLIC_API_KEY"
#             value_from {
#               config_map_key_ref {
#                 key      = "NEXT_PUBLIC_FIREBASE_PUBLIC_API_KEY"
#                 name     = "my-box-ui-config-map"
#                 optional = false
#               }
#             }
#           }

#           env {
#             name = "NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN"
#             value_from {
#               config_map_key_ref {
#                 key      = "NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN"
#                 name     = "my-box-ui-config-map"
#                 optional = false
#               }
#             }
#           }

#           env {
#             name = "NEXT_PUBLIC_FIREBASE_DATABASE_URL"
#             value_from {
#               config_map_key_ref {
#                 key      = "NEXT_PUBLIC_FIREBASE_DATABASE_URL"
#                 name     = "my-box-ui-config-map"
#                 optional = false
#               }
#             }
#           }

#           env {
#             name = "NEXT_PUBLIC_FIREBASE_PROJECT_ID"
#             value_from {
#               config_map_key_ref {
#                 key      = "NEXT_PUBLIC_FIREBASE_PROJECT_ID"
#                 name     = "my-box-ui-config-map"
#                 optional = false
#               }
#             }
#           }

#           env {
#             name = "FIREBASE_PRIVATE_KEY"
#             value_from {
#               secret_key_ref {
#                 key      = "FIREBASE_PRIVATE_KEY"
#                 name     = "my-box-ui-secret"
#                 optional = false
#               }
#             }
#           }

#           env {
#             name = "COOKIE_SECRET_CURRENT"
#             value_from {
#               config_map_key_ref {
#                 key      = "COOKIE_SECRET_CURRENT"
#                 name     = "my-box-ui-config-map"
#                 optional = false
#               }
#             }
#           }

#           env {
#             name = "COOKIE_SECRET_PREVIOUS"
#             value_from {
#               config_map_key_ref {
#                 key      = "COOKIE_SECRET_PREVIOUS"
#                 name     = "my-box-ui-config-map"
#                 optional = false
#               }
#             }
#           }

#           env {
#             name = "NEXT_PUBLIC_COOKIE_SECURE"
#             value_from {
#               config_map_key_ref {
#                 key      = "NEXT_PUBLIC_COOKIE_SECURE"
#                 name     = "my-box-ui-config-map"
#                 optional = false
#               }
#             }
#           }

#           env {
#             name = "NEXT_PUBLIC_FIREBASE_APP_NAME"
#             value_from {
#               config_map_key_ref {
#                 key      = "NEXT_PUBLIC_FIREBASE_APP_NAME"
#                 name     = "my-box-ui-config-map"
#                 optional = false
#               }
#             }
#           }

#           resources {
#             limits = {
#               cpu    = "400m"
#               memory = "512Mi"
#             }
#             requests = {
#               cpu    = "300m"
#               memory = "256Mi"
#             }
#           }

#           # liveness_probe {
#           #   http_get {
#           #     path = "/login"
#           #     port = local.my_box_ui_port

#           #     http_header {
#           #       name  = "X-Custom-Header"
#           #       value = "Awesome"
#           #     }
#           #   }

#           #   initial_delay_seconds = 3
#           #   period_seconds        = 3
#           # }
#         }
#       }
#     }
#   }
#   depends_on = [
#     google_container_cluster.primary
#   ]
# }

# resource "kubernetes_config_map" "my_box_ui_config_map" {
#   count = var.profile_enabled ? 1 : 0

#   metadata {
#     name = "my-box-ui-config-map"
#   }

#   data = {
#     NEXT_PUBLIC_API_HOST = var.next_public_api_host
#     FIREBASE_CLIENT_EMAIL = var.firebase_client_email
#     NEXT_PUBLIC_FIREBASE_PUBLIC_API_KEY = var.next_public_firebase_public_api_key
#     NEXT_PUBLIC_FIREBASE_AUTH_DOMAIN = var.next_public_firebase_auth_domain
#     NEXT_PUBLIC_FIREBASE_DATABASE_URL = var.next_public_firebase_database_url
#     NEXT_PUBLIC_FIREBASE_PROJECT_ID = var.next_public_firebase_project_id
#     COOKIE_SECRET_CURRENT = var.cookie_secret_current
#     COOKIE_SECRET_PREVIOUS = var.cookie_secret_previous
#     NEXT_PUBLIC_COOKIE_SECURE = var.next_public_cookie_secure
#     NEXT_PUBLIC_FIREBASE_APP_NAME = var.next_public_firebase_app_name
#   }
# }

# resource "kubernetes_secret" "my_box_ui_secret" {
#   metadata {
#     name = "my-box-ui-secret"
#   }

#   data = {
#     FIREBASE_PRIVATE_KEY = var.firebase_private_key
#   }
# }

# resource "kubernetes_service" "my_box_ui" {
#   metadata {
#     name = "my-box-ui-service"
#     labels = {
#       "app" = "my-box-ui"
#     }
#   }
#   spec {
#     selector = {
#       app = kubernetes_deployment.my_box_ui.metadata.0.labels.app
#     }
#     port {
#       port        = local.my_box_ui_port
#       target_port = local.my_box_ui_port
#     }

#     type = "NodePort"
#   }
#   depends_on = [
#     kubernetes_deployment.my_box_ui
#   ]
# }
