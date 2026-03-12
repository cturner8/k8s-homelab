terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
  }
}

provider "azurerm" {
  storage_use_azuread = true
  features {}
  resource_provider_registrations = "none"
}

data "azurerm_client_config" "current" {}
