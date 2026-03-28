module "aks_identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "~> 0.4.0"

  enable_telemetry    = false
  name                = module.naming.user_assigned_identity.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  role_assignments = {
    vnet_contributor = {
      role_definition_id_or_name = "Network Contributor"
      description                = "Assign the Network Contributor role to the specified user assigned managed identity for AKS"
      scope                      = module.aks_dns.resource_id
    }
  }
}

module "admin_identity" {
  source  = "Azure/avm-res-managedidentity-userassignedidentity/azurerm"
  version = "~> 0.4.0"

  enable_telemetry    = false
  name                = module.admin_naming.user_assigned_identity.name
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location
}

module "cert_manager_identity" {
  source = "./modules/workload-identity"

  naming_suffixes     = [local.suffix, "certmanager"]
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  oidc_issuer_url           = module.aks.oidc_issuer_profile_issuer_url
  service_account_name      = "cert-manager"
  service_account_namespace = "cert-manager"
}

module "oauth_proxy_identity" {
  source = "./modules/workload-identity"

  naming_suffixes     = [local.suffix, "oauthproxy"]
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  oidc_issuer_url           = module.aks.oidc_issuer_profile_issuer_url
  service_account_name      = "oauth2-proxy"
  service_account_namespace = "oauth2-proxy"
}
