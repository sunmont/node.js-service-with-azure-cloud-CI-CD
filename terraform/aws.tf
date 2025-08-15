# Use official modules for a clean, production-ready EKS + VPC
# VPC
module "vpc" {
  count  = var.cloud == "aws" ? 1 : 0
  source = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${var.cluster_name}-vpc"
  cidr = "10.0.00/16"

  azs             = ["${var.aws_region}a", "${var.aws_region}b"]
  private_subnets = ["10.0.1.0/24",    "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24",  "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
}

# EKS Cluster + Managed Node Group
module "eks" {
  count  = var.cloud == "aws" ? 1 : 0
  source = "terraform-aws-modules/eks/aws"
  version = "~> 20.8"

  cluster_name    = "${var.cluster_name}-eks"
  cluster_version = "1.29"

  vpc_id                         = module.vpc[0].vpc_id
  subnet_ids                     = concat(module.vpc[0].private_subnets, module.vpc[0].public_subnets)
  cluster_endpoint_public_access = true

  eks_managed_node_groups = {
    default = {
      min_size     = var.node_count
      max_size     = var.node_count + 2
      desired_size = var.node_count
      instance_types = ["t3.medium"]
    }
  }
}

# ECR Repository
resource "aws_ecr_repository" "ecr" {
  count = var.cloud == "aws" ? 1 : 0
  name  = "${var.cluster_name}-repo"
  image_scanning_configuration { scan_on_push = true }
  force_delete = true
}
