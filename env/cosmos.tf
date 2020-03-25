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