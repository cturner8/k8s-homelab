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

  role_assignments = {
    aks_network_contributor = {
      role_definition_id_or_name = "Network Contributor"
      principal_id               = module.aks_identity.principal_id
    }
  }
}

resource "azurerm_public_ip" "admin_nat" {
  name                = "${module.admin_naming.public_ip.name}-nat"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_public_ip" "bastion" {
  name                = "${module.admin_naming.public_ip.name}-bastion"
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_nat_gateway" "admin_gateway" {
  name                = module.admin_naming.nat_gateway.name
  location            = data.azurerm_resource_group.rg.location
  resource_group_name = data.azurerm_resource_group.rg.name
  sku_name            = "Standard"
}

resource "azurerm_nat_gateway_public_ip_association" "admin_gateway_ip" {
  nat_gateway_id       = azurerm_nat_gateway.admin_gateway.id
  public_ip_address_id = azurerm_public_ip.admin_nat.id
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
      nat_gateway = {
        id = azurerm_nat_gateway.admin_gateway.id
      }
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
      reverse_allow_virtual_network_access = false
      reverse_allow_forwarded_traffic      = false
      reverse_allow_gateway_transit        = false
      reverse_use_remote_gateways          = false
    }
  }
}
