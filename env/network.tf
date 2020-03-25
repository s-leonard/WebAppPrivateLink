resource "azurerm_virtual_network" "main" {
  name                = "acctestvnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "vnetint" {
  name                 = "vnetint"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "10.0.1.0/24"

  delegation {
    name = "vnetintdelegation"
    service_delegation {
      name    = "Microsoft.Web/serverFarms"
      actions = ["Microsoft.Network/virtualNetworks/subnets/action"]
    }
  }
}

resource "azurerm_subnet" "apiprivatelink" {
  name                 = "apiprivatelnk"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "10.0.2.0/24"
  enforce_private_link_service_network_policies  = true 
  enforce_private_link_endpoint_network_policies  = true
}


resource "azurerm_subnet" "dbprivatelink" {
  name                 = "dbprivatelnk"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "10.0.3.0/24"
  enforce_private_link_service_network_policies   = true 
  enforce_private_link_endpoint_network_policies  = true
}


resource "azurerm_network_security_group" "vnetint" {
  name                = "vnetintsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}


resource "azurerm_subnet_network_security_group_association" "vnetint" {
  subnet_id                 = azurerm_subnet.vnetint.id
  network_security_group_id = azurerm_network_security_group.vnetint.id
}