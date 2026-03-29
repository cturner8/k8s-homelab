locals {
  vault_private_endpoints = {
    primary = {
      private_dns_zone_resource_ids = [module.vault_dns.resource_id]
      subnet_resource_id            = module.aks_vnet.subnets["private_endpoints"].resource_id
    }
  }
}

module "admin_vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "~> 0.10.2"

  enable_telemetry              = false
  location                      = data.azurerm_resource_group.rg.location
  resource_group_name           = data.azurerm_resource_group.rg.name
  name                          = module.admin_naming.key_vault.name_unique
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = false
  network_acls = {
    default_action = "Deny"
  }

  private_endpoints = local.vault_private_endpoints


  role_assignments = {
    kv_admin = {
      principal_id               = data.azurerm_client_config.current.object_id
      role_definition_id_or_name = "Key Vault Administrator"
    }
    admin_kv_secrets_officer = {
      principal_id               = module.admin_identity.principal_id
      role_definition_id_or_name = "Key Vault Secrets Officer"
    }
  }
}

module "vault" {
  source  = "Azure/avm-res-keyvault-vault/azurerm"
  version = "~> 0.10.2"

  enable_telemetry              = false
  location                      = data.azurerm_resource_group.rg.location
  resource_group_name           = data.azurerm_resource_group.rg.name
  name                          = module.naming.key_vault.name_unique
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  public_network_access_enabled = false
  network_acls = {
    default_action = "Deny"
  }

  private_endpoints = local.vault_private_endpoints

  role_assignments = {
    kv_admin = {
      principal_id               = data.azurerm_client_config.current.object_id
      role_definition_id_or_name = "Key Vault Administrator"
    }
    aks_kv_secrets_provider = {
      principal_id               = module.aks.key_vault_secrets_provider_identity.objectId
      role_definition_id_or_name = "Key Vault Secrets User"
    }
    admin_kv_secrets_officer = {
      principal_id               = module.admin_identity.principal_id
      role_definition_id_or_name = "Key Vault Secrets Officer"
    }
  }


  secrets = {
    oauth_proxy_cookie_secret = {
      name = "oauth-proxy-cookie-secret"
    }
  }
  secrets_value = {
    oauth_proxy_cookie_secret = random_password.oauth_proxy_cookie_secret.result
  }
}
