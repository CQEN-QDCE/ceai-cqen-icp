locals {
  cluster_name          = var.cluster_name
  region                = var.cluster_region
  eks_version           = "1.30"
  aws_profile           = var.aws_profile
  environment           = var.environment
  assume_role_arn       = var.assume_role_arn
  sso_path              = "/aws-reserved/sso.amazonaws.com/${var.cluster_region}/"
  subnet_ids            = [module.sea_network.app_subnet_a.id, module.sea_network.app_subnet_b.id]
  using_assume_role_arn = var.assume_role_arn != null

  get_token_command = local.using_assume_role_arn ? ["eks", "get-token", "--cluster-name", local.cluster_name] : ["eks", "get-token", "--cluster-name", local.cluster_name, "--profile", local.aws_profile]

  tags = {
    Platform    = var.cluster_name
    Environment = var.environment
  }

}

module "ceai_lib" {
  source = "github.com/CQEN-QDCE/ceai-cqen-terraform-lib?ref=v4.0"
}

module "sea_network" {
  source = "./.terraform/modules/ceai_lib/aws/sea-network"

  aws_profile           = local.aws_profile
  workload_account_type = var.workload_account_type

}