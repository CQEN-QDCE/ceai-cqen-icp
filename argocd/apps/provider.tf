
data "aws_availability_zones" "available" {}

provider "aws" {
  region  = var.cluster_region
  default_tags {
    tags = {
      system = var.cluster_name
    }
  }
  profile = var.aws_profile != "" ? var.aws_profile : null
}

data "aws_eks_cluster" "cluster" {
  name = var.cluster_name
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.cluster.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.cluster.certificate_authority[0].data)
  exec {
    api_version = "client.authentication.k8s.io/v1beta1"
    command     = "aws"
    args        = local.get_token_command
  }
}
