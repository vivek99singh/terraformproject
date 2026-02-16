module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  vnet_cidr           = var.vnet_cidr
  subnet_cidrs        = var.subnet_cidrs
}

module "vm" {
  source                             = "./modules/vm"
  resource_group_name                = azurerm_resource_group.main.name
  location                           = var.location
  subnet_id                          = module.network.subnet_ids[0]
  public_ip_id                       = module.network.public_ip_id
  nsg_id                             = module.network.nsg_id
  vm_size                            = var.vm_size
  admin_username                     = var.admin_username
  boot_diagnostics_storage_account_uri = azurerm_storage_account.bootdiag.primary_blob_endpoint
}

resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.location

  tags = {
    Environment = "Dev"
    Service     = "terraform-managed"
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
}

resource "random_string" "storage_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "azurerm_storage_account" "bootdiag" {
  name                     = "bootdiag${random_string.storage_suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"

  tags = {
    Environment = "Dev"
    Service     = "terraform-managed"
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
}