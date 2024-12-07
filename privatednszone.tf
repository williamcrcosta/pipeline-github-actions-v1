resource "azurerm_private_dns_zone" "storagezone" {
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_private_dns_zone_virtual_network_link" "linkzonestoragespoke" {
  name                  = "linkzonestoragespoke"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storagezone.name
  virtual_network_id    = azurerm_virtual_network.vnet_spoke.id
}

resource "azurerm_private_dns_zone_virtual_network_link" "linkzonestoragehub" {
  name                  = "linkzonestoragehub"
  resource_group_name   = azurerm_resource_group.rg.name
  private_dns_zone_name = azurerm_private_dns_zone.storagezone.name
  virtual_network_id    = azurerm_virtual_network.vnet_hub.id
}

resource "azurerm_private_endpoint" "storage_prd_endpoint" {
  name                = "storage-prd-endpoint"
  location            = var.location01-eastus2
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.sub-pvt-001.id

  private_service_connection {
    name                           = "storage-prd-connection"
    private_connection_resource_id = azurerm_storage_account.storage_prd.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.storagezone.id]
  }
}

resource "azurerm_private_endpoint" "storage_dev_endpoint" {
  name                = "storage-dev-endpoint"
  location            = var.location02-westus2
  resource_group_name = azurerm_resource_group.rg.name
  subnet_id           = azurerm_subnet.sub-pvt-hub-001.id

  private_service_connection {
    name                           = "storage-dev-connection"
    private_connection_resource_id = azurerm_storage_account.storage_dev.id
    subresource_names              = ["blob"]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "privatednszonegroup"
    private_dns_zone_ids = [azurerm_private_dns_zone.storagezone.id]
  }
}