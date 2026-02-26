module "network" {
  source              = "./modules/network"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vnet_cidr           = var.vnet_cidr
  subnet_cidrs        = var.subnet_cidrs
  tags                = var.tags
}

module "storage" {
  source              = "./modules/storage"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = var.tags
}

module "vm" {
  source              = "./modules/vm"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  subnet_id           = module.network.subnet_id
  nsg_id              = module.network.nsg_id
  tags                = var.tags
  vm_name             = var.vm_name
  vm_size             = var.vm_size
  admin_username      = var.admin_username
  boot_diagnostics_storage_account_uri = module.storage.primary_blob_endpoint
}