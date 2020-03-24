
resource "azurerm_app_service_plan" "api" {
  name                = "plan-${var.resource_group_name}-${random_id.main.dec}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  kind                = "Windows"

  sku {
    tier = "Premium"
    size = "P2v2"
  }
}

resource "azurerm_app_service" "api" {
  name                = "web-${var.resource_group_name}-${random_id.main.dec}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  app_service_plan_id = azurerm_app_service_plan.api.id
}

resource "azurerm_app_service_virtual_network_swift_connection" "api" {
  app_service_id = azurerm_app_service.api.id
  subnet_id      = azurerm_subnet.vnetint.id
}