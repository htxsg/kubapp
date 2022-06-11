# Configure the Azure provider
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 2.65"
    }
  }
}

resource "random_pet" "prefix" {}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "rg" {
  name     = "${random_pet.prefix.id}-rg"
  location = var.region
  tags = {
    project     = var.project,
    environment = var.environment
  }
}

resource "azurerm_container_registry" "acr" {
  name     = local.acr_name
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  sku                      = "Basic"
  admin_enabled            = true
  }





