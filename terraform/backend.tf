terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }

  backend "azurerm" {
    resource_group_name  = "terraformproject"
    storage_account_name = "tfstate9022026"
    container_name       = "tfstate"
    key                  = "terraform-rgwindows.tfstate"
  }
}
