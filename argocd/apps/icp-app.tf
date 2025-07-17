################################################################################
# Déploiement d'une application ICP EJBCA via ArgoCD
################################################################################

resource "kubernetes_manifest" "icp_app_of_apps" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "icp-ejbca-${terraform.workspace}"
      namespace = "argocd"
      labels = {
        "app.kubernetes.io/name"    = "icp-ejbca-${terraform.workspace}"
        "app.kubernetes.io/part-of" = "xroad-${terraform.workspace}"
      }
    }
    spec = {
      project = "${terraform.workspace}"
      source = {
        repoURL        = var.repo_github_url
        targetRevision = var.target_revision
        path           = var.chart_path
        helm = {
          values = yamlencode({
            server_image   = var.server_image
            server_tag_icp     = var.image_tag
            ingressIcp = {
              annotations = {
                subnetAllowList   = "${module.sea_network.web_subnet_a.id}, ${module.sea_network.web_subnet_b.id}"
                acmCertificateArn = var.acm_certificate_arn
              }
            }
            env = {
              DATABASE_JDBC_URL = var.DATABASE_JDBC_URL
              DATABASE_USER     = var.DATABASE_USER
              DATABASE_PASSWORD = var.DATABASE_PASSWORD
            }
          })
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "xroad-${terraform.workspace}"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }
  depends_on = [
    kubernetes_manifest.argocd_project
  ]
}
