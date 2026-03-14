module "cert_manager_identity" {
  source = "./modules/workload-identity"

  naming_suffixes     = [local.suffix, "certmanager"]
  resource_group_name = data.azurerm_resource_group.rg.name
  location            = data.azurerm_resource_group.rg.location

  oidc_issuer_url           = module.aks.oidc_issuer_profile_issuer_url
  service_account_name      = "cert-manager"
  service_account_namespace = "cert-manager"
}
