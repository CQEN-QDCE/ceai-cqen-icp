
resource "kubernetes_manifest" "argocd_project" {
  #for_each = toset(var.stages)

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


resource "kubernetes_manifest" "argocd_github_app_secret" {
  manifest = {
    apiVersion = "v1"
    kind       = "Secret"
    metadata = {
      name      = "argocd-repo-github-app-${terraform.workspace}"
      namespace = "argocd"
      labels = {
        "argocd.argoproj.io/secret-type" = "repository"
      }
    }
    type = "Opaque"
    data = {
      url                     = base64encode(var.repo_github_ifra_url)
      type                    = base64encode("git")
      githubAppID             = base64encode(var.github_app_id)
      githubAppInstallationID = base64encode(var.github_app_installation_id)
      githubAppPrivateKey     = base64encode(var.github_app_private_key)
      project                 = base64encode("${terraform.workspace}")
    }
  }
}