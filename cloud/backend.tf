terraform {
  backend "azurerm" {
    use_azuread_auth     = true
    storage_account_name = "stdeploy72q4knlzcvh66"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
