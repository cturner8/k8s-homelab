module "aks" {
  source  = "Azure/avm-res-containerservice-managedcluster/azurerm"
  version = "~> 0.5.2"

  name      = module.naming.kubernetes_cluster.name
  location  = data.azurerm_resource_group.rg.location
  parent_id = data.azurerm_resource_group.rg.id

  network_profile = {
    network_plugin = "azure"
  }

  api_server_access_profile = {
    enable_vnet_integration            = true
    enable_private_cluster             = true
    enable_private_cluster_public_fqdn = false
    private_dns_zone                   = "system"
    subnet_id                          = module.aks_vnet.subnets["apiserver"].resource_id
  }

  public_network_access = "Disabled"

  default_agent_pool = {
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 2
    vm_size             = "Standard_B2ls_v2"
    zones               = ["1"]

    vnet_subnet_id = module.aks_vnet.subnets["nodes"].resource_id
  }

  ingress_profile = {
    web_app_routing = {
      enabled               = true
      dns_zone_resource_ids = [module.dns.resource_id]
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
