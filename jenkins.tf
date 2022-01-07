locals {
  pre_installed_plugins = [
    "kubernetes:1.30.11",
    "workflow-aggregator:2.6",
    "git:4.10.0",
    "configuration-as-code:1.55"
  ]
  service_port = "8080"
  target_port = "8080"
}

resource "helm_release" "jenkinsci" {
  name       = "jenkinsci"

  repository = "https://charts.jenkins.io"
  chart      = "jenkins"

  set {
    name  = "controller.serviceType"
    value = "NodePort"
  }

  set {
    name  = "controller.targetPort"
    value = local.target_port
  }

  set {
    name  = "controller.adminUser"
    value = var.jenkins_admin_username
  }

  set {
    name  = "controller.adminPassword"
    value = var.jenkins_admin_password
  }

  set {
    name  = "controller.servicePort"
    value = local.service_port
  }

  set {
    name = "persistence.size"
    value = "50Gi"
  }

  set {
    name = "controller.installPlugins"
    value = "{${join(",", local.pre_installed_plugins)}}"
  }

  set {
    name = "serviceAccount.create"
    value = "true"
  }

  set {
    name = "serviceAccount.name"
    value = "jenkins"
  }

  depends_on = [
    kubernetes_persistent_volume.jenkins_pv
  ]
}

resource "kubernetes_persistent_volume" "jenkins_pv" {
  metadata {
    name = "jenkins-pv"
  }
  spec {
    capacity = {
      storage = "50Gi"
    }
    access_modes = ["ReadWriteMany"]
    storage_class_name = "jenkins-pv"
    persistent_volume_source {
      gce_persistent_disk {
        fs_type = "ext4"
        pd_name = "my-gke-disk"
      }
    }
  }
}
