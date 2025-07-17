terraform {
  backend "s3" {
    bucket               = "x-road-preprod-github-action-ressources"
    workspace_key_prefix = "environments"
    key                  = "xroad-k8s/terraform.tfstate"
    region               = "ca-central-1"
    profile              = "xroad-preprod"   
  }
}