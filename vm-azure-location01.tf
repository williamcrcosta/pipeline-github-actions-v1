/*resource "azurerm_resource_group" "rg-vm" {
  name     = "rg-vm"
  location = "eastus2"
  tags     = local.common_tags
}*/

resource "azurerm_public_ip" "pip-vm-eastus2" {
  name                = "pip-vm-eastus2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location01-eastus2
  allocation_method   = "Static"
  tags                = local.common_tags
}

resource "azurerm_network_interface" "nic-vm-eastus2" {
  name                = "nic-vm-eastus2"
  location            = var.location01-eastus2
  resource_group_name = azurerm_resource_group.rg.name
  tags                = local.common_tags
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.sub-web-001.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.11.1.4"
    public_ip_address_id          = azurerm_public_ip.pip-vm-eastus2.id
  }
}

# Ja esta no codigo remoto
/*resource "azurerm_subnet_network_security_group_association" "subsga" {
  subnet_id                 = data.terraform_remote_state.vnet.outputs.subnet_id
  network_security_group_id = data.terraform_remote_state.vnet.outputs.security_group_id
}*/

resource "azurerm_linux_virtual_machine" "vm-eastus2" {
  name                = "vm-eastus2"
  resource_group_name = azurerm_resource_group.rg.name
  location            = var.location01-eastus2
  size                = "Standard_B1s"
  admin_username      = "terraform"
  network_interface_ids = [
    azurerm_network_interface.nic-vm-eastus2.id,
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
    storage_account_uri = azurerm_storage_account.storage_prd.primary_blob_endpoint
  }

  tags = local.common_tags
}