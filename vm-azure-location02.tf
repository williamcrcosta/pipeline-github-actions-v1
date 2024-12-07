/*resource "azurerm_resource_group" "rg-vm" {
  name     = "rg-vm"
  location = "eastus2"
  tags     = local.common_tags
}*/

resource "azurerm_public_ip" "pip-vm" {
  name                = "pip-vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location02-westus2
  allocation_method   = "Static"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "nic-vm" {
  name                = "nic-vm"
  location            = var.location02-westus2
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub-srv-001.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.10.1.4"
    public_ip_address_id          = azurerm_public_ip.pip-vm.id
  }
}

# Ja esta no codigo remoto
/*resource "azurerm_subnet_network_security_group_association" "subsga" {
  subnet_id                 = data.terraform_remote_state.vnet.outputs.subnet_id
  network_security_group_id = data.terraform_remote_state.vnet.outputs.security_group_id
}*/

resource "azurerm_linux_virtual_machine" "vm" {
  name                = "vm"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location02-westus2
  size                = "Standard_B1s"
  admin_username      = "terraform"
  network_interface_ids = [
    azurerm_network_interface.nic-vm.id,
  ]

  admin_ssh_key {
    username   = "terraform"
    public_key = var.azure_key_pub
    //public_key = file("./azure-key2.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  /*source_image_reference {
    publisher = "canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }*/
  source_image_reference {
    publisher = "Canonical"
    offer     = "ubuntu-24_04-lts"
    sku       = "server"
    version   = "latest"
  }

  provision_vm_agent = true
  vtpm_enabled       = true

  boot_diagnostics {
    storage_account_uri = azurerm_storage_account.storage_dev.primary_blob_endpoint
  }

  tags = local.common_tags
}