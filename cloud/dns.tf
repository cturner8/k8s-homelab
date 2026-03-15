// TODO: add cloudflare dns integration for registration of Azure DNS nameservers

module "dns" {
  source  = "Azure/avm-res-network-dnszone/azurerm"
  version = "~> 0.2.1"

  name                = var.domain_name
  resource_group_name = data.azurerm_resource_group.rg.name
  enable_telemetry    = false
}

module "dns_role_assignment" {
  source  = "Azure/avm-res-authorization-roleassignment/azurerm"
  version = "~> 0.3.0"

  enable_telemetry = false
  role_definitions = {
    dns_contributor = {
      name = "DNS Zone Contributor"
    }
  }
  user_assigned_managed_identities_by_principal_id = {
    aks_ingress_identity  = module.aks.ingress_profile_web_app_routing_identity.objectId
    cert_manager_identity = module.cert_manager_identity.principal_id
  }
  role_assignments_for_resources = {
    dns_zone = {
      resource_name       = var.domain_name
      resource_group_name = data.azurerm_resource_group.rg.name
      role_assignments = {
        dns_contributor = {
          role_definition = "dns_contributor"
          user_assigned_managed_identities = [
            "aks_ingress_identity",
            "cert_manager_identity"
          ]
        }
      }
    }
  }

  depends_on = [module.dns]
}
