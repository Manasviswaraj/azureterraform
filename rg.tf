# Create a resource group
resource "azurerm_resource_group" "rg-wtf" {
  name     = "rg-with-terraform"
  location = "West Europe"
}