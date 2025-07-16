# tflint-ignore: terraform_unused_declarations
variable "cluster_name" {
  description = "Name of cluster"
  type        = string

  validation {
    condition     = length(var.cluster_name) > 0 && length(var.cluster_name) <= 19
    error_message = "The cluster name must be between [1, 19] characters"
  }

  default = "xroad-eks-test"
}

variable "cluster_region" {
  description = "Region to create the cluster"
  type        = string
  default     = "ca-central-1"
}

variable "aws_profile" {
  type        = string
  description = "Optional: If an SSO connection is being used, specify the SSO profile name in the .aws/config file on the machine executing the deployment."
  default     = null
}

variable "assume_role_arn" {
  type        = string
  description = "The ARN of the role to assume"
  default     = null
}

/*variable "workload_account_type" {
  type        = string
  description = "The type of workload account LZA to create"
  default     = "Dev"
}*/

variable "environment" {
  type        = string
  description = "Name of system environment deployed on AWS"
  default     = "preprod"
}

variable "acm_certificate_arn" {
  description = "ACM certificate ARN for the load balancer"
  type        = string
}

/*
variable "repo_github_ifra_url" {
  description = "The URL of the repository"
  type        = string
}

variable "repo_github_ifra_target_revision" {
  description = "The target revision of the repository"
  type        = string
}

variable "github_app_id" {
  description = "GitHub App ID"
  type        = string
  sensitive   = true
}

variable "github_app_installation_id" {
  description = "GitHub App Installation ID"
  type        = string
  sensitive   = true
}

variable "github_app_private_key" {
  description = "GitHub App Private Key"
  type        = string
  sensitive   = true
} */

variable "repo_github_url_icp" {
  description = "The URL of the repository de l'ICP EJBCA"
  type        = string
}

variable "target_revision_icp" {
  description = "The target revision of the repository ICP EJBCA"
  type        = string
}

variable "chart_path_icp" {
  description = "Le chemin vers le repertoire du helm chart de l'icp dans le repo"
  type        = string
}

variable "server_image_icp" {
  description = "valeur du nom de l'image de l'icp EJBCA"
  type        = string
}

variable "image_tag_icp" {
  description = "le tag de l'image de l'icp EJBCA"
  type        = string
} 

variable "repo_github_url" {
  description = "The URL of the repository"
  type        = string
}

/*variable "target_revision" {
  description = "The target revision of the repository"
  type        = string
}*/

/*
variable "chart_path_test_argocd" {
  description = "The path to the chart in the repository for the app de test argo cd"
  type        = string
}

variable "server_image_test_argo" {
  description = "value of the image repo for the sapp de test argo cd"
  type        = string
}

variable "image_tag_test_argo" {
  description = "value of the image tag for the app de test argo cd"
  type        = string
}
*/ 
