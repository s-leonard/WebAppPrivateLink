resource "azurerm_resource_group" "hub" {
    name     = local.resource_group_hub_name
    location = var.location
}
resource "azurerm_resource_group" "spoke" {
    name     = local.resource_group_spoke_name
    location = var.location
}

resource "random_id" "spoke" {
  keepers = {
    # Generate a new ID only when a new resource group is defined
    resource_group_spoke_name = "${azurerm_resource_group.spoke.name}"
    resource_group_hub_name = "${azurerm_resource_group.hub.name}"
  }

  byte_length = 2
}
