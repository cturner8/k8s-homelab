terraform {
  backend "azurerm" {
    use_azuread_auth     = true
    storage_account_name = "stdeploycwee2wu2d3pzg"
    container_name       = "tfstate"
    key                  = "dev.terraform.tfstate"
  }
}
