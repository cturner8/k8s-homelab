variable "resource_group_name" {
  type        = string
  description = "The deployment Resource Group."
}

variable "location" {
  type        = string
  description = "The deployment location."
}

variable "service_account_name" {
  type        = string
  description = "The name of the Kubernetes Service Account for the Workload Identity."
}

variable "service_account_namespace" {
  type        = string
  description = "The Kubernetes Namespace of the Service Account."
}

variable "oidc_issuer_url" {
  type        = string
  description = "The Workload Identity OIDC Issuer URL."
}

variable "naming_suffixes" {
  type        = list(string)
  description = "Resource naming suffixes."
}
