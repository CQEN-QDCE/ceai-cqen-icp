
resource "kubernetes_manifest" "argocd_project" {

  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "AppProject"
    metadata = {
      name      = "${terraform.workspace}"
      namespace = "argocd"
    }
    spec = {
      description = "X-Road Central service project for ${terraform.workspace}"
      sourceRepos = [
        "*"
      ]
      destinations = [
        {
          namespace = "xroad-${terraform.workspace}"
          server    = "https://kubernetes.default.svc"
        }
      ]
      clusterResourceWhitelist = [
        {
          group = "*"
          kind  = "*"
        }
      ]
      namespaceResourceWhitelist = [
        {
          group = "*"
          kind  = "*"
        }
      ]
    }
  }
}
