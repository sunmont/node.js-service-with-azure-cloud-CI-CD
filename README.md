Node.js Service, OpenID Connect, RBAC, docker, CI/CD with GitHub Actions and Terraform🐳

This repository demonstrates how to:
- Provision **AKS (Azure)** or **EKS (AWS)** clusters using **Terraform**.
- Automatically **build & push Docker images** from **GitHub** to **ACR** or **ECR**.
- Deploy to Kubernetes using a **cloud-neutral YAML**.
- Attach **Persistent Volumes** with Azure Disks or AWS EBS.
- Switch clouds easily by changing one Terraform variable.

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


