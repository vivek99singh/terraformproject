resource "azurerm_resource_group" "main" {
  name     = "rg-resource"
  location = "eastus"

  tags = {
    Environment = "Dev"
    Service     = "terraform-managed"
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
}

resource "random_string" "bootdiag" {
  length  = 12
  special = false
}

resource "azurerm_storage_account" "bootdiag" {
  name                     = "bootdiag${random_string.bootdiag.result}"
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

module "network" {
  source              = "./modules/network"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  vnet_cidr           = "10.0.0.0/16"
  subnet_cidrs        = ["10.0.1.0/24", "10.0.2.0/24"]
}

module "vm" {
  source                           = "./modules/vm"
  resource_group_name              = azurerm_resource_group.main.name
  location                         = azurerm_resource_group.main.location
  subnet_id                        = module.network.subnet_ids[0]
  public_ip_id                     = module.network.public_ip_id
  nsg_id                           = module.network.nsg_id
  vm_size                          = "Standard_D2s_v5"
  admin_username                   = "adminuser"
  boot_diagnostics_storage_account_uri = azurerm_storage_account.bootdiag.primary_blob_endpoint
}