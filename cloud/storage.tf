module "storage" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.6.7"

  name                            = module.naming.storage_account.name_unique
  resource_group_name             = data.azurerm_resource_group.rg.name
  location                        = data.azurerm_resource_group.rg.location
  account_kind                    = "StorageV2"
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  default_to_oauth_authentication = true
  local_user_enabled              = false
  https_traffic_only_enabled      = true
  enable_telemetry                = false
  lock = {
    kind = "CanNotDelete"
  }

  public_network_access_enabled = false
  network_rules = {
    default_action = "Deny"
  }

  private_endpoints = {
    file = {
      private_dns_zone_resource_ids = [module.file_dns.resource_id]
      subnet_resource_id            = module.aks_vnet.subnets["private_endpoints"].resource_id
      subresource_name              = "file"
    }
    blob = {
      private_dns_zone_resource_ids = [module.blob_dns.resource_id]
      subnet_resource_id            = module.aks_vnet.subnets["private_endpoints"].resource_id
      subresource_name              = "blob"
    }
  }

  role_assignments = {
    blob_data_contributor = {
      principal_id               = data.azurerm_client_config.current.object_id
      role_definition_id_or_name = "Storage Blob Data Contributor"
    }
    file_data_contributor = {
      principal_id               = data.azurerm_client_config.current.object_id
      role_definition_id_or_name = "Storage File Data Contributor"
    }
    admin_blob_data_contributor = {
      principal_id               = module.admin_identity.principal_id
      role_definition_id_or_name = "Storage Blob Data Contributor"
    }
    admin_file_data_contributor = {
      principal_id               = module.admin_identity.principal_id
      role_definition_id_or_name = "Storage File Data Contributor"
    }
  }
}
