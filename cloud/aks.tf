module "aks" {
  source  = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version = "0.5.2"

  name      = module.naming.kubernetes_cluster.name
  location  = data.azurerm_resource_group.rg.location
  parent_id = data.azurerm_resource_group.rg.id

  default_agent_pool = {
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 2
    vm_size             = "Standard_B2ls_v2"
    zones               = ["1"]
  }

  ingress_profile = {
    web_app_routing = {
      enabled = true
    }
  }

  addon_profile_key_vault_secrets_provider = {
    enabled = true
  }

  aad_profile = {
    managed                = true
    enable_azure_rbac      = true
    admin_group_object_ids = [var.admin_group_id]
  }

  oidc_issuer_profile = {
    enabled = true
  }

  storage_profile = {
    blob_csi_driver = {
      enabled = true
    }
  }

  security_profile = {
    image_cleaner = {
      enabled        = true
      interval_hours = 24
    }
    workload_identity = {
      enabled = true
    }
  }

  disable_local_accounts = true
  enable_rbac            = true
  enable_telemetry       = false

  kubernetes_version = "1.34"

  sku = {
    name = "Base"
    tier = "Standard"
  }
}
