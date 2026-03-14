// TODO: add cloudflare dns integration for registration of Azure DNS nameservers

module "dns" {
  source  = "Azure/avm-res-network-dnszone/azurerm"
  version = "0.2.1"

  name                = var.domain_name
  resource_group_name = data.azurerm_resource_group.rg.name
  enable_telemetry    = false
}
