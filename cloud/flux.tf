resource "azurerm_kubernetes_cluster_extension" "flux" {
  name           = "flux"
  cluster_id     = module.aks.resource_id
  extension_type = "microsoft.flux"

  depends_on = [
    azurerm_resource_provider_registration.kubernetes_configuration,
    # azurerm_resource_provider_registration.kubernetes
  ]
}

resource "azurerm_kubernetes_flux_configuration" "flux" {
  name       = "flux-system"
  cluster_id = module.aks.resource_id
  namespace  = "flux-system"
  scope      = "cluster"

  git_repository {
    url             = "https://github.com/cturner8/k8s-homelab.git"
    reference_type  = "branch"
    reference_value = "azure"
  }

  kustomizations {
    name                       = "infra"
    path                       = "./infra/development"
    recreating_enabled         = true
    garbage_collection_enabled = true
  }

  kustomizations {
    name                       = "configs"
    path                       = "./infra/development/configs"
    recreating_enabled         = true
    garbage_collection_enabled = true

    post_build {
      substitute = {
        AZURE_RESOURCE_GROUP_NAME       = data.azurerm_resource_group.rg.name
        AZURE_SUBSCRIPTION_ID           = data.azurerm_client_config.current.subscription_id
        DOMAIN_NAME                     = var.domain_name
        CERT_MANAGER_IDENTITY_CLIENT_ID = module.cert_manager_identity.client_id
      }
    }

    depends_on = ["infra"]
  }

  kustomizations {
    name                       = "apps"
    path                       = "./apps/development"
    recreating_enabled         = true
    garbage_collection_enabled = true

    depends_on = ["infra", "configs"]
  }

  depends_on = [azurerm_kubernetes_cluster_extension.flux]
}
