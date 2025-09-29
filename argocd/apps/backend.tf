terraform {
  backend "s3" {
    bucket               = "x-road-preprod-github-action-ressources"
    workspace_key_prefix = "environments"
    key                  = "projects/base/apps/icp/terraform.tfstate"
    region               = "ca-central-1"
    profile              = "xroad-preprod"   
    #profile              = "dev-cqen"   
  }
}