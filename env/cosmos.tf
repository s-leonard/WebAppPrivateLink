resource "azurerm_cosmosdb_account" "main" {
  name                = "cosmosacc-${var.resource_group_name}-${random_id.main.dec}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_automatic_failover = false

  consistency_policy {
    consistency_level   = "Session"
  }

   geo_location {
    prefix            = "cosmosaccloc-${var.resource_group_name}-${random_id.main.dec}"
    location          = azurerm_resource_group.main.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "main" {
  name                = "cosmosdb-${var.resource_group_name}-${random_id.main.dec}"
  resource_group_name = azurerm_resource_group.main.name
  account_name        = azurerm_cosmosdb_account.main.name
  throughput          = 400
}

resource "azurerm_private_endpoint" "dbendpoint" {
  name                = "dbendpoint-${var.resource_group_name}-${random_id.main.dec}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  subnet_id           = azurerm_subnet.dbprivatelink.id

  private_service_connection {
    is_manual_connection       = false
    name                       = "connection-${var.resource_group_name}-${random_id.main.dec}"
    private_connection_resource_id = azurerm_cosmosdb_account.main.id
    subresource_names          = ["SQL"]
  }
}
