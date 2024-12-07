/*terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

#provider "azurerm" {
#  features {}
#}
*/

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location01-eastus2
  tags     = local.common_tags
}

resource "azurerm_virtual_network" "vnet_hub" {
  name                = "vnet-hub-001"
  address_space       = ["10.10.0.0/16"]
  location            = var.location02-westus2
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
}

resource "azurerm_subnet" "sub-srv-001" {
  name                 = "sub-srv-001"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_hub.name
  address_prefixes     = ["10.10.1.0/24"]
}

resource "azurerm_subnet" "sub-pvt-hub-001" {
  name                 = "sub-pvt-hub-001"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_hub.name
  address_prefixes     = ["10.10.10.0/24"]

  private_endpoint_network_policies = "NetworkSecurityGroupEnabled"
}

resource "azurerm_network_security_group" "nsg_pvt_hub" {
  name                = "nsg-pvt-hub-001"
  location            = var.location02-westus2
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  security_rule {
    name                       = "Allow-PVT"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.10.1.4"
    destination_address_prefix = "10.10.10.4"
  }
}
/*resource "azurerm_subnet" "sub-srv-001" {
  name                 = "sub-srv-001"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_hub.name
  address_prefixes       = "10.10.1.0/24"
}*/

resource "azurerm_network_security_group" "nsg_hub" {
  name                = "nsg-hub-001"
  location            = var.location02-westus2
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  security_rule {
    name                       = "Allow-SSH-VM-APPs"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "10.10.1.4"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_hub_association" {
  subnet_id                 = azurerm_subnet.sub-srv-001.id
  network_security_group_id = azurerm_network_security_group.nsg_hub.id
}

resource "azurerm_virtual_network" "vnet_spoke" {
  name                = "vnet-spk-001"
  address_space       = ["10.11.0.0/16"]
  location            = var.location01-eastus2
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
}

resource "azurerm_subnet" "sub-web-001" {
  name                 = "sub-web-001"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_spoke.name
  address_prefixes     = ["10.11.1.0/24"]
}

resource "azurerm_subnet" "sub-web-002" {
  name                 = "sub-web-002"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_spoke.name
  address_prefixes     = ["10.11.2.0/24"]
}

resource "azurerm_subnet" "sub-pvt-001" {
  name                 = "sub-pvt-001"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet_spoke.name
  address_prefixes     = ["10.11.10.0/24"]

  private_endpoint_network_policies = "NetworkSecurityGroupEnabled"
}

resource "azurerm_network_security_group" "nsg_pvt" {
  name                = "nsg-pvt-001"
  location            = var.location01-eastus2
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  security_rule {
    name                       = "Allow-HTTPs"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.11.1.4"
    destination_address_prefix = "10.11.10.4"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_pvt_associations" {
  //for_each                  = toset([azurerm_subnet.sub-web-001.id, azurerm_subnet.sub-web-002.id])
  subnet_id                 = azurerm_subnet.sub-pvt-001.id
  network_security_group_id = azurerm_network_security_group.nsg_pvt.id
}

resource "azurerm_network_security_group" "nsg_spoke" {
  name                = "nsg-spk-001"
  location            = var.location01-eastus2
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags

  security_rule {
    name                       = "Allow-SSH-VM-APPs"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "10.11.1.4"
  }
}

resource "azurerm_subnet_network_security_group_association" "nsg_spoke_associations" {
  //for_each                  = toset([azurerm_subnet.sub-web-001.id, azurerm_subnet.sub-web-002.id])
  for_each                  = local.subnets_map
  subnet_id                 = each.value
  network_security_group_id = azurerm_network_security_group.nsg_spoke.id
}

resource "azurerm_virtual_network_peering" "hub_to_spoke" {
  name                      = "HubToSpoke"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet_hub.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_spoke.id
  allow_forwarded_traffic   = true
}

resource "azurerm_virtual_network_peering" "spoke_to_hub" {
  name                      = "SpokeToHub"
  resource_group_name       = azurerm_resource_group.rg.name
  virtual_network_name      = azurerm_virtual_network.vnet_spoke.name
  remote_virtual_network_id = azurerm_virtual_network.vnet_hub.id
  allow_forwarded_traffic   = true
}


resource "azurerm_storage_account" "storage_prd" {
  name                     = "stotftecsp${random_integer.rand.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location01-eastus2
  account_tier             = "Standard"
  account_replication_type = "LRS"
  //kind                     = "StorageV2"
  //allow_blob_public_access = true
  tags                          = local.common_tags
  public_network_access_enabled = false
}

resource "azurerm_storage_container" "container_prd" {
  name = "imagens"
  //storage_account_name = azurerm_storage_account.storage_prd.name
  storage_account_id    = azurerm_storage_account.storage_prd.id
  container_access_type = "blob"
}

resource "random_integer" "rand" {
  min = 100000
  max = 999999
}

resource "azurerm_storage_account" "storage_dev" {
  name                     = "stotftecspdev${random_integer.rand.result}"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = var.location02-westus2
  account_tier             = "Standard"
  account_replication_type = "LRS"
  //kind                     = "StorageV2"
  //allow_blob_public_access = true
  tags                          = local.common_tags
  public_network_access_enabled = false
}

resource "azurerm_storage_container" "container_dev" {
  name = "imagens"
  //storage_account_name = azurerm_storage_account.storage_dev.name
  storage_account_id    = azurerm_storage_account.storage_dev.id
  container_access_type = "blob"
}
