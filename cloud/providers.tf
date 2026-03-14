# Registers resource providers required for AKS Flux extension and configurations.
# `Microsoft.ContainerService` is automatically managed by terraform so is not required here.

resource "azurerm_resource_provider_registration" "kubernetes" {
  name = "Microsoft.Kubernetes"
}

resource "azurerm_resource_provider_registration" "kubernetes_configuration" {
  name = "Microsoft.KubernetesConfiguration"
}
