
resource "kubernetes_ingress" "services" {
  metadata {
    name = "services"
  }

  spec {
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

    rule {
      host = "gogin.${local.personal_hosted_zone}"
      http {
        path {
          backend {
            service_name = kubernetes_service.gogin_framework.metadata.0.name
            service_port = kubernetes_service.gogin_framework.spec.0.port.0.target_port
          }
          path = "/*"
        }
      }
    }
  }
  depends_on = [
    kubernetes_service.my_resume,
    kubernetes_service.gogin_framework
  ]
}

resource "aws_route53_record" "gogin" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = "gogin"
  type    = "A"
  ttl     = "300"
  records = [
    kubernetes_ingress.services.status.0.load_balancer.0.ingress.0.ip
  ]
  allow_overwrite = true
  depends_on = [
    kubernetes_ingress.services,
    aws_route53_zone.primary
  ]
}

resource "aws_route53_record" "root_domain" {
  zone_id = aws_route53_zone.primary.zone_id
  name    = ""
  type    = "A"
  ttl     = "300"
  records = [
    kubernetes_ingress.services.status.0.load_balancer.0.ingress.0.ip
  ]
  allow_overwrite = true

  depends_on = [
    kubernetes_ingress.services,
    aws_route53_zone.primary
  ]
}
