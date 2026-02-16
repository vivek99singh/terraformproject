module "azure_sql_database" {
  source              = "./modules/azure_sql_database"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}