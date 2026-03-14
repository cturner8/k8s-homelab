resource "azurerm_kubernetes_cluster_extension" "flux" {
  name           = "flux"
  cluster_id     = module.aks.resource_id
  extension_type = "microsoft.flux"
}

resource "azurerm_kubernetes_flux_configuration" "apps" {
  name       = "apps"
  cluster_id = module.aks.resource_id
  namespace  = "flux-system"
  scope      = "cluster"

  git_repository {
    url             = "https://github.com/cturner8/k8s-homelab.git"
    reference_type  = "branch"
    reference_value = "azure"
  }

  kustomizations {
    name = "flux-system"
    path = "./apps/development"
  }

  depends_on = [azurerm_kubernetes_cluster_extension.flux]
}
