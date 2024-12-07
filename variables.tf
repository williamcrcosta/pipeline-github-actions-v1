# Resource Group
variable "resource_group_name" {
  default = "rg-vm"
}

# RGion

/*variable "location" {
  description = "Região onde os recursos serão criados na Azure"
  type        = map(string)
  default = {
    "eastus2" = "eastus2"
    "brazil"  = "brazilsouth"
    "asia"    = "Japan East"
    "westus"  = "westus"
  }
}*/



# Regions
variable "location01-eastus2" {
  #  default = "uksouth" # Original
  #  default = "eastus2"
  default = "eastus2"
}

variable "location02-westus2" {
  #  default = "brazilsouth"
  #  default = "centralus"
  default = "West US 2"
}

/*variable "location03-mexicocentral" {
  #  default = "brazilsouth"
  #  default = "centralus"
  default = "Mexico Central"
}*/

# Credentials
variable "azure_key_pub" {
  description = "Chave publica para maquina no Azure"
  type        = string
}

variable "tags" {
  default = {
    Environment = "Labs"
    Evento      = "Imersão TFTEC 2024"
  }
}