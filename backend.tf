terraform {
  backend "azurerm" {
    resource_group_name  = "rg-terraform-state"
    storage_account_name = "williamcostatfstate"
    container_name       = "remote-state"
    key                  = "VMs-Regions-GitHUB/terraform.tfstate"
  }
}

/*provider "azurerm" {
  features {}
}*/
