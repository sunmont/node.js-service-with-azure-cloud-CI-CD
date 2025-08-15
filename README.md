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

##
Set cloud = "azure" or cloud = "aws" in infra/terraform.tfvars

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

GitHub Secrets to set
Secret	              For	          Example
CLOUD	                both	        azure or aws
AZURE_CREDENTIALS    	Azure login	  JSON from az ad sp create-for-rbac --sdk-auth
AZURE_ACR_NAME	      ACR	          myappacr123
AZURE_RG	            AKS RG	      From Terraform output (e.g., myapp-rg)
AZURE_AKS_NAME	      AKS name	    From Terraform output (e.g., myapp-aks)
AWS_ACCESS_KEY_ID    	AWS	          Your IAM key
AWS_SECRET_ACCESS_KEY	AWS	          Your IAM secret
AWS_EKS_NAME	        EKS cluster	  From TF output (e.g., myapp-eks)
AWS_ECR_REPO_NAME	    ECR repo name	From TF (e.g., myapp-repo)

After terraform apply, check outputs (terraform output -json) to fill these secrets accurately.

🚀 How to use

Provision infra

cd infra
cp terraform.tfvars.example terraform.tfvars
# edit terraform.tfvars with your creds and set cloud = "azure" or "aws"
terraform init
terraform apply


Set repo secrets (table above).

Push to main
GitHub Actions will build → push → apply manifests → rolling update (hot deploy, zero downtime).





