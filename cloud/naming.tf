# This ensures we have unique CAF compliant names for our resources.
module "naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4.3"

  suffix = [local.suffix]
}

module "admin_naming" {
  source  = "Azure/naming/azurerm"
  version = "~> 0.4.3"

  suffix = [local.suffix, "admin"]
}
