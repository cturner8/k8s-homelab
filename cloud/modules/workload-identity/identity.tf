module "identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "~> 0.4.0"

  enable_telemetry    = false
  name                = module.naming.user_assigned_identity.name
  resource_group_name = var.resource_group_name
  location            = var.location
  federated_identity_credentials = {
    workload_identity = {
      name     = "workload-identity"
      issuer   = var.oidc_issuer_url
      audience = ["api://AzureADTokenExchange"]
      subject  = "system:serviceaccount:${var.service_account_namespace}:${var.service_account_name}"
    }
  }
}
