variable "cloud" {
  description = "Target cloud: 'azure' or 'aws'"
  type        = string
}

# ----- Azure -----
variable "azure_subscription_id" { type = string }
variable "azure_client_id"       { type = string }
variable "azure_client_secret"   { type = string }
variable "azure_tenant_id"       { type = string }
variable "azure_region"          { type = string  default = "eastus" }

# ----- AWS -----
variable "aws_region"     { type = string  default = "us-east-1" }
variable "aws_access_key" { type = string }
variable "aws_secret_key" { type = string }

# ----- Common -----
variable "cluster_name" {
  description = "Logical cluster name prefix"
  type        = string
  default     = "myapp"
}

variable "node_count" {
  type    = number
  default = 2
}

# AKS node size
variable "node_size" {
  type    = string
  default = "Standard_DS2_v2"
}
