locals {
  is_azure = var.cloud == "azure"
  is_aws   = var.cloud == "aws"
}

# ----- Azure outputs -----
output "azure_acr_login_server" {
  value       = local.is_azure ? azurerm_container_registry.acr[0].login_server : null
  description = "ACR login server (e.g., myacr.azurecr.io)"
}

output "azure_acr_admin_username" {
  value       = local.is_azure ? azurerm_container_registry.acr[0].admin_username : null
  sensitive   = true
}

output "azure_acr_admin_password" {
  value       = local.is_azure ? azurerm_container_registry.acr[0].admin_password : null
  sensitive   = true
}

output "aks_kube_config_raw" {
  value       = local.is_azure ? azurerm_kubernetes_cluster.aks[0].kube_config_raw : null
  sensitive   = true
}

output "aks_rg" {
  value       = local.is_azure ? azurerm_resource_group.rg[0].name : null
}

output "aks_name" {
  value       = local.is_azure ? azurerm_kubernetes_cluster.aks[0].name : null
}

# ----- AWS outputs -----
output "aws_ecr_repo_url" {
  value       = local.is_aws ? aws_ecr_repository.ecr[0].repository_url : null
  description = "ECR repo URL (e.g., acct.dkr.ecr.us-east-1.amazonaws.com/my-repo)"
}

output "eks_name" {
  value       = local.is_aws ? module.eks[0].cluster_name : null
}

output "eks_region" {
  value       = local.is_aws ? var.aws_region : null
}

output "eks_endpoint" {
  value       = local.is_aws ? module.eks[0].cluster_endpoint : null
}

output "eks_ca" {
  value       = local.is_aws ? module.eks[0].cluster_certificate_authority_data : null
  sensitive   = true
}
