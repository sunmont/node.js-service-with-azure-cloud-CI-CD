Node.js Service, OpenID Connect, RBAC, docker, CI/CD with GitHub Actions and Terraform🐳

# Multi-Cloud Hot Deploy with Terraform, AKS, and EKS

This repo provisions AKS and EKS clusters using Terraform and sets up GitHub Actions for zero-downtime deployments.

## Features
- Deploys AKS and EKS clusters from a single Terraform codebase.
- Builds Docker images from GitHub.
- Pushes images to Azure Container Registry and Amazon ECR.
- Rolling updates for zero downtime.
- Same YAML manifests for both clouds.

## Deployment Flow
1. Developer pushes to `main`.
2. GitHub Actions builds and pushes image with unique tag.
3. AKS and EKS deployments are updated with `kubectl set image`.
4. Kubernetes replaces Pods gradually (rolling update).

## Prerequisites
- Terraform 1.4+
- Azure CLI
- AWS CLI
- Docker

## Hot Deploy
Rolling updates ensure no service downtime during deployment.

Edit `terraform/variables.tf`:

```hcl
variable "cloud" {
  type    = string
  default = "azure" # change to "aws" for AWS EKS
}

## How to Run
```bash
terraform init
terraform apply

## 📂 Project Structure

.
├── terraform/ # Terraform IaC for AKS/EKS + ACR/ECR  
│ ├── main.tf  
│ ├── variables.tf  
│ ├── outputs.tf  
│ └── provider.tf  
├── k8s/ # Cloud-neutral Kubernetes manifests  
│ ├── deployment.yaml  
│ ├── service.yaml  
│ └── pvc.yaml  
├── .github/  
│ └── workflows/  
│ └── deploy.yml # GitHub Actions pipeline  
├── Dockerfile  
├── docker-compose.yml  
├── .env  
├── src  
│ └── routes/  
|      ...   
| └── auth.ts  
| └── config.ts  
| └── server.ts  
| ...  
├── package.json  
├── tsconfig.json  
└── README.md  




