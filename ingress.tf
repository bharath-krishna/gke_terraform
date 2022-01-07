
resource "kubernetes_ingress" "services" {
  wait_for_load_balancer = true
  metadata {
    name = "services"
    # annotations = {
    #   "networking.gke.io/managed-certificates" = google_compute_managed_ssl_certificate.bharathk_domain_tls.name
    # }
  }

  spec {
    tls {
      hosts = [local.personal_hosted_zone]
      secret_name = kubernetes_secret.tls_cert_key.metadata.0.name
    }

    rule {
      host = local.personal_hosted_zone
      http {
        path {
          backend {
            service_name = kubernetes_service.my_resume.metadata.0.name
            service_port = kubernetes_service.my_resume.spec.0.port.0.target_port
          }
          path = "/*"
        }
      }
    }

    # rule {
    #   host = "gogin.${local.personal_hosted_zone}"
    #   http {
    #     path {
    #       backend {
    #         service_name = kubernetes_service.gogin_framework.metadata.0.name
    #         service_port = local.gogin_target_port
    #       }
    #       path = "/*"
    #     }
    #   }
    # }

    # rule {
    #   host = "box-ui.${local.personal_hosted_zone}"
    #   http {
    #     path {
    #       backend {
    #         service_name = kubernetes_service.my_box_ui.metadata.0.name
    #         service_port = kubernetes_service.my_box_ui.spec.0.port.0.target_port
    #       }
    #       path = "/*"
    #     }
    #   }
    # }

    rule {
      host = "box-api.${local.personal_hosted_zone}"
      http {
        path {
          backend {
            service_name = kubernetes_service.my_box_api.metadata.0.name
            service_port = kubernetes_service.my_box_api.spec.0.port.0.target_port
          }
          path = "/*"
        }
      }
    }

    rule {
      host = "jenkins.${local.personal_hosted_zone}"
      http {
        path {
          backend {
            service_name = helm_release.jenkinsci.metadata.0.name
            service_port = local.target_port
          }
          path = "/*"
        }
      }
    }

    rule {
      host = "auth.bharathk.in"
      http {
        path {
          backend {
            service_name = kubernetes_service.keycloak.metadata.0.name
            service_port = local.keycloak_port
          }
        path = "/*"
        }
      }
    }
  }
  depends_on = [
    helm_release.jenkinsci,
    # kubernetes_deployment.gogin_framework,
    kubernetes_deployment.my_box_api,
    kubernetes_deployment.my_resume,
    kubernetes_deployment.keycloak
    # kubernetes_secret.tls_cert_key
  ]
}

# resource "aws_route53_record" "gogin" {
#   zone_id = var.bharathk_in_hosted_zone_id
#   name    = "gogin"
#   type    = "A"
#   ttl     = "300"
#   records = [
#     kubernetes_ingress.services.status.0.load_balancer.0.ingress.0.ip
#   ]
#   allow_overwrite = true
#   depends_on = [
#     kubernetes_ingress.services
#   ]
# }

resource "aws_route53_record" "root_domain" {
  zone_id = var.bharathk_in_hosted_zone_id
  name    = ""
  type    = "A"
  ttl     = "300"
  records = [
    kubernetes_ingress.services.status.0.load_balancer.0.ingress.0.ip
  ]
  allow_overwrite = true

  depends_on = [
    kubernetes_ingress.services
  ]
}

resource "aws_route53_record" "my_box_api" {
  zone_id = var.bharathk_in_hosted_zone_id
  name    = "box-api"
  type    = "A"
  ttl     = "300"
  records = [
    kubernetes_ingress.services.status.0.load_balancer.0.ingress.0.ip
  ]
  allow_overwrite = true

  depends_on = [
    kubernetes_ingress.services
  ]
}

resource "aws_route53_record" "keycloak" {
  zone_id = var.bharathk_in_hosted_zone_id
  name    = "auth"
  type    = "A"
  ttl     = "300"
  records = [
    kubernetes_ingress.services.status.0.load_balancer.0.ingress.0.ip
  ]
  allow_overwrite = true

  depends_on = [
    kubernetes_ingress.services
  ]
}

resource "aws_route53_record" "jenkins" {
  zone_id = var.bharathk_in_hosted_zone_id
  name    = "jenkins"
  type    = "A"
  ttl     = "300"
  records = [
    kubernetes_ingress.services.status.0.load_balancer.0.ingress.0.ip
  ]
  allow_overwrite = true

  depends_on = [
    kubernetes_ingress.services
  ]
}

resource "aws_route53_record" "my_box_ui" {
  zone_id = var.bharathk_in_hosted_zone_id
  name    = "box-ui"
  type    = "CNAME"
  ttl     = "300"
  records = [
    var.vercel_app_domain_cname
  ]
  allow_overwrite = true

  depends_on = [
    kubernetes_ingress.services
  ]
}

resource "kubernetes_secret" "tls_cert_key" {
  metadata {
    name = "tls"
  }
  data = {
    "tls.crt" = "${file("/Users/bharath.krishna/.ssh/gke-tls-ingress.crt")}"
    "tls.key" = "${file("/Users/bharath.krishna/.ssh/gke-tls-ingress.key")}"
  }
  type = "kubernetes.io/tls"
}
