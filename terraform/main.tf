resource "azurerm_resource_group" "main" {
  name     = "rg-vm-network"
  location = var.location

  tags = {
    Environment = var.environment
    Service     = "vm-network-service"
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
}

resource "azurerm_storage_account" "bootdiag" {
  name                     = "bootdiag${random_string.unique_sa_name.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = var.environment
    Service     = "boot-diagnostics"
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
}

resource "random_string" "unique_sa_name" {
  length  = 12
  special = false
  upper   = false
}

module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_cidr           = var.vnet_cidr
  subnet_cidrs        = var.subnet_cidrs
}

module "vm" {
  source                            = "./modules/vm"
  resource_group_name               = azurerm_resource_group.main.name
  location                          = azurerm_resource_group.main.location
  subnet_id                         = module.network.subnet_ids[0]
  public_ip_id                      = module.network.public_ip_id
  nsg_id                            = module.network.nsg_id
  vm_size                           = var.vm_size
  admin_username                    = var.admin_username
  boot_diagnostics_storage_account_uri = azurerm_storage_account.bootdiag.primary_blob_endpoint
}