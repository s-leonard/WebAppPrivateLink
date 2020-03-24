provider "azurerm" {
  version         = "~>2.0"
  features {}
  #features {}
  #subscription_id = var.azure_subscription_id
  #client_id       = var.azure_subscription_client_id
  #client_secret   = var.azure_subscription_client_secret
  #tenant_id       = var.azure_tenant_id
}
#terraform {
#  backend "azurerm" {
  # }
#}
provider "random" {
  version = "~> 2.2"
}
resource "azurerm_resource_group" "main" {
    name     = var.resource_group_name
    location = var.location
}

resource "random_id" "main" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group = "${azurerm_resource_group.main.name}"
  }

  byte_length = 2
}

