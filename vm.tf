resource "azurerm_resource_group" "myrg" {
  name     = "myrg"
  location = "East Asia" # Change as needed
}

resource "azurerm_virtual_network" "Vnet" {
  name                = "myVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
}

resource "azurerm_subnet" "subnet1" {
  name                 = "mySubnet"
  resource_group_name  = azurerm_resource_group.myrg.name
  virtual_network_name = azurerm_virtual_network.Vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_public_ip" "myPublicIP" {
  name                = "myPublicIP"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "mynic" {
  name                = "myNIC"
  location            = azurerm_resource_group.myrg.location
  resource_group_name = azurerm_resource_group.myrg.name

  ip_configuration {
    name                          = "myIPConfig"
    subnet_id                     = azurerm_subnet.subnet1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.myPublicIP.id
  }
}



resource "azurerm_linux_virtual_machine" "example" {
  name                = "myLinuxVM"
  resource_group_name = azurerm_resource_group.myrg.name
  location            = azurerm_resource_group.myrg.location
  size                = "Standard_B1s" # Low-cost VM size
  admin_username      = "azureuser"

  # Use the SSH key for authentication
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("C:\\Users\\Manasvi\\Downloads\\mykeypaz.pub")

    # Make sure to have the public key
  }

  network_interface_ids = [azurerm_network_interface.mynic.id]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS" # Required argument
    disk_size_gb         = 30             # Optional, but good to specify
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }
}

output "public_ip" {
  value = azurerm_public_ip.myPublicIP.ip_address
}
