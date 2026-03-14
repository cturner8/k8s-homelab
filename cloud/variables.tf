variable "resource_group_name" {
  type        = string
  description = "Azure Resource Group to use for deployments."
  default     = "rg-k8s-homelab-dev"
}

variable "admin_group_id" {
  type        = string
  description = "Microsoft Entra ID group to provide AKS admin access to."
}

variable "domain_name" {
  type        = string
  description = "Domain name to use for the cluster public DNS Zone."
}
