########################################
# main.tf — Cross-cloud Kubernetes wiring
########################################

locals {
  is_azure = var.cloud == "azure"
  is_aws   = var.cloud == "aws"
}

# AKS <-> ACR image pull permission (Azure only)
resource "azurerm_role_assignment" "aks_acr_pull" {
  count                = local.is_azure ? 1 : 0
  scope                = azurerm_container_registry.acr[0].id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks[0].kubelet_identity[0].object_id
}

# EKS auth data (AWS only)
data "aws_eks_cluster" "eks" {
  count = local.is_aws ? 1 : 0
  name  = module.eks[0].cluster_name
}

data "aws_eks_cluster_auth" "eks" {
  count = local.is_aws ? 1 : 0
  name  = module.eks[0].cluster_name
}

# Kubernetes provider configured for either AKS or EKS
provider "kubernetes" {
  host = local.is_azure
    ? azurerm_kubernetes_cluster.aks[0].kube_config[0].host
    : data.aws_eks_cluster.eks[0].endpoint

  client_certificate = local.is_azure
    ? base64decode(azurerm_kubernetes_cluster.aks[0].kube_config[0].client_certificate)
    : null

  client_key = local.is_azure
    ? base64decode(azurerm_kubernetes_cluster.aks[0].kube_config[0].client_key)
    : null

  cluster_ca_certificate = local.is_azure
    ? base64decode(azurerm_kubernetes_cluster.aks[0].kube_config[0].cluster_ca_certificate)
    : base64decode(data.aws_eks_cluster.eks[0].certificate_authority[0].data)

  token = local.is_aws ? data.aws_eks_cluster_auth.eks[0].token : null
}
