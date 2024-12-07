locals {
  common_tags = {
    Owner     = "William Costa"
    ManagedBy = "Terraform"
  }
}

locals {
  subnets_map = {
    "sub-web-001" = azurerm_subnet.sub-web-001.id
    "sub-web-002" = azurerm_subnet.sub-web-002.id
  }
}