module "aks_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.1"

  location         = data.azurerm_resource_group.rg.location
  parent_id        = data.azurerm_resource_group.rg.id
  address_space    = ["10.0.0.0/16"]
  enable_telemetry = false
  name             = module.naming.virtual_network.name

  subnets = {
    nodes = {
      name             = "snet-aks-nodes"
      address_prefixes = ["10.0.1.0/24"]
    }
    apiserver = {
      name             = "snet-aks-apiserver"
      address_prefixes = ["10.0.0.0/28"]
      delegations = [
        {
          name = "Microsoft.ContainerService.managedClusters"
          service_delegation = {
            name = "Microsoft.ContainerService/managedClusters"
          }
        }
      ]
    }
    private_endpoints = {
      name             = "snet-aks-private-endpoints"
      address_prefixes = ["10.0.2.0/24"]
    }
  }
}

module "admin_vnet" {
  source  = "Azure/avm-res-network-virtualnetwork/azurerm"
  version = "0.17.1"

  location         = data.azurerm_resource_group.rg.location
  parent_id        = data.azurerm_resource_group.rg.id
  address_space    = ["10.1.0.0/16"]
  enable_telemetry = false
  name             = module.admin_naming.virtual_network.name

  subnets = {
    admin = {
      name             = "snet-admin"
      address_prefixes = ["10.1.1.0/24"]
    }
    bastion = {
      name             = "AzureBastionSubnet"
      address_prefixes = ["10.1.0.0/26"]
    }
  }

  peerings = {
    aks_vnet = {
      remote_virtual_network_resource_id   = module.aks_vnet.resource_id
      name                                 = "admin-vnet-aks-vnet"
      allow_virtual_network_access         = true
      allow_forwarded_traffic              = false
      allow_gateway_transit                = false
      use_remote_gateways                  = false
      create_reverse_peering               = true
      reverse_name                         = "aks-vnet-admin-vnet"
      reverse_allow_virtual_network_access = true
      reverse_allow_forwarded_traffic      = false
      reverse_allow_gateway_transit        = false
      reverse_use_remote_gateways          = false
    }
  }
}
