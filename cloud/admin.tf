data "azurerm_key_vault_key" "admin_vm_ssh_key" {
  name         = "admin-vm-ssh-key"
  key_vault_id = module.admin_vault.resource_id

  depends_on = [module.admin_vault.keys]
}

module "bastion" {
  source  = "Azure/avm-res-network-bastionhost/azurerm"
  version = "0.9.0"

  location         = data.azurerm_resource_group.rg.location
  name             = module.admin_naming.bastion_host.name_unique
  parent_id        = data.azurerm_resource_group.rg.id
  enable_telemetry = false
  ip_configuration = {
    name                 = "bastion-ipconfig"
    subnet_id            = module.admin_vnet.subnets["bastion"].resource_id
    public_ip_address_id = azurerm_public_ip.admin_nat.id
    create_public_ip     = false
  }
  sku = "Basic"

  copy_paste_enabled = true
  tunneling_enabled  = true

  zones = azurerm_public_ip.admin_nat.zones
}

module "admin_vm" {
  source  = "Azure/avm-res-compute-virtualmachine/azurerm"
  version = "0.20.0"

  location = data.azurerm_resource_group.rg.location
  name     = module.admin_naming.virtual_machine.name_unique
  network_interfaces = {
    network_interface_1 = {
      name                           = module.admin_naming.network_interface.name_unique
      accelerated_networking_enabled = true
      ip_forwarding_enabled          = true
      ip_configurations = {
        ip_configuration_1 = {
          name                          = "${module.admin_naming.network_interface.name_unique}-nic1-ipconfig1"
          private_ip_subnet_resource_id = module.admin_vnet.subnets["admin"].resource_id
          create_public_ip_address      = false

        }
      }
      resource_group_name = data.azurerm_resource_group.rg.name
      is_primary          = true
    }
  }
  resource_group_name = data.azurerm_resource_group.rg.name
  zone                = null

  account_credentials = {
    admin_credentials = {
      username                           = "aks-homelab-admin"
      generate_admin_password_or_ssh_key = false
      password_authentication_disabled   = true
      ssh_keys                           = [data.azurerm_key_vault_key.admin_vm_ssh_key.public_key_openssh]
    }
  }

  custom_data = base64encode(file("${path.module}/templates/cloud-init.yml"))

  enable_telemetry           = false
  encryption_at_host_enabled = false

  managed_identities = {
    system_assigned            = true
    user_assigned_resource_ids = [module.admin_identity.resource_id]
  }

  os_disk = {
    caching              = "ReadWrite"
    storage_account_type = "Premium_LRS"
  }

  os_type = "Linux"

  enable_automatic_updates = true

  role_assignments = {
    vm_admin_login = {
      role_definition_id_or_name = "Virtual Machine Administrator Login"
      description                = "Assign the Virtual Machine Administrator Login role to the specified user"
      principal_type             = "User"
      principal_id               = data.azurerm_client_config.current.object_id
    }
    vm_user_login = {
      role_definition_id_or_name = "Virtual Machine User Login"
      description                = "Assign the Virtual Machine User Login role to the specified user"
      principal_type             = "User"
      principal_id               = data.azurerm_client_config.current.object_id
    }
  }
  role_assignments_system_managed_identity = {
    kv_secrets_user = {
      scope_resource_id          = module.admin_vault.resource_id
      role_definition_id_or_name = "Key Vault Secrets User"
      description                = "Assign the Key Vault Secrets User role to the virtual machine's system managed identity"
      principal_type             = "ServicePrincipal"
    }
  }

  sku_size = var.admin_vm_size

  source_image_reference = {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server-arm64"
    version   = "latest"
  }

  priority        = "Spot"
  eviction_policy = "Deallocate"

  extensions = {
    aad_ssh = {
      name                       = "AADSSHLoginForLinux"
      publisher                  = "Microsoft.Azure.ActiveDirectory"
      type                       = "AADSSHLoginForLinux"
      type_handler_version       = "1.0"
      auto_upgrade_minor_version = true
    }
  }

  # Needs NAT gateway and public IP association to be created first to allow outbound internet connectivity 
  depends_on = [azurerm_nat_gateway_public_ip_association.admin_gateway_ip]
}
