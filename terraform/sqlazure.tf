module "azure_sql" {
  source              = "./modules/azure-sql"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}