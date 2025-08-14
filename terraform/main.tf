########################################
# main.tf — cross-cloud Kubernetes wiring
########################################

# Add the Kubernetes provider to the required providers.
terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.26"
    }
  }
}

# Convenience flags
locals {
  is_azure = var.cloud == "azure"
  is_aws   = var.cloud == "aws"
}

########################################
# AKS <-> ACR pull permission (Azure only)
########################################
# Ensures AKS nodes can pull images from ACR without imagePullSecrets.
resource "azurerm_role_assignment" "aks_acr_pull" {
  count                = local.is_azure ? 1 : 0
  scope                = azurerm_container_registry.acr[0].id
  role_definition_name = "AcrPull"
  principal_id         = azurerm_kubernetes_cluster.aks[0].kubelet_identity[0].object_id
}

########################################
# EKS data sources for auth (AWS only)
########################################
# These fetch the cluster endpoint, CA bundle, and a short-lived auth token.
data "aws_eks_cluster" "eks" {
  count = local.is_aws ? 1 : 0
  name  = aws_eks_cluster.eks[0].name
}

data "aws_eks_cluster_auth" "eks" {
  count = local.is_aws ? 1 : 0
  name  = aws_eks_cluster.eks[0].name
}

########################################
# Kubernetes provider (works for AKS or EKS)
########################################
# AKS uses client certs from the cluster resource.
# EKS uses endpoint + CA + token from the data sources above.
provider "kubernetes" {
  host = local.is_azure
    ? azurerm_kubernetes_cluster.aks[0].kube_config[0].host
    : data.aws_eks_cluster.eks[0].endpoint

  # ---- AKS auth (client certs) ----
  client_certificate = local.is_azure
    ? base64decode(azurerm_kubernetes_cluster.aks[0].kube_config[0].client_certificate)
    : null

  client_key = local.is_azure
    ? base64decode(azurerm_kubernetes_cluster.aks[0].kube_config[0].client_key)
    : null

  cluster_ca_certificate = local.is_azure
    ? base64decode(azurerm_kubernetes_cluster.aks[0].kube_config[0].cluster_ca_certificate)
    : base64deco
