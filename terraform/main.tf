terraform {
  required_version = ">= 1.4.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.0"
    }
  }
}

provider "azurerm" {
  features {}
}

provider "aws" {
  region = var.aws_region
}

# --- Azure AKS ---
resource "azurerm_resource_group" "rg" {
  name     = "multi-cloud-k8s-rg"
  location = var.azure_location
}

resource "azurerm_kubernetes_cluster" "aks" {
  name                = "multi-cloud-aks"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "multicloud"

  default_node_pool {
    name       = "default"
    node_count = 2
    vm_size    = "Standard_DS2_v2"
  }

  identity {
    type = "SystemAssigned"
  }
}

# --- AWS EKS ---
resource "aws_eks_cluster" "eks" {
  name     = "multi-cloud-eks"
  role_arn = aws_iam_role.eks_role.arn

  vpc_config {
    subnet_ids = var.aws_subnet_ids
  }

  depends_on = [aws_iam_role_policy_attachment.eks_policy_attach]
}

resource "aws_iam_role" "eks_role" {
  name = "eksClusterRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Principal = {
          Service = "eks.amazonaws.com"
        },
        Effect = "Allow"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_policy_attach" {
  role       = aws_iam_role.eks_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Output kubeconfigs for GitHub Actions
output "aks_kube_config" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "eks_endpoint" {
  value = aws_eks_cluster.eks.endpoint
}

output "eks_certificate_authority" {
  value = aws_eks_cluster.eks.certificate_authority[0].data
}

output "eks_name" {
  value = aws_eks_cluster.eks.name
}
