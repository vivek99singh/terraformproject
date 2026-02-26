module "azure_sql" {
  source              = "./modules/azure-sql"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  tags                = var.tags
}