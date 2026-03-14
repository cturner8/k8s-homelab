module "storage" {
  source  = "Azure/avm-res-storage-storageaccount/azurerm"
  version = "~> 0.6.7"

  name                            = module.naming.storage_account.name
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
}
