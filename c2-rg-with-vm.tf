resource "azurerm_resource_group" "provisioner-vm" {
  name = var.rg-name
  location = "eastus"
}

resource "azurerm_virtual_network" "provioner-vnet" {
  name = var.vnet-name
  location = azurerm_resource_group.provisioner-vm.location
  resource_group_name = azurerm_resource_group.provisioner-vm.name
  address_space = [ "10.100.0.0/24" ]
  depends_on = [ azurerm_resource_group.provisioner-vm ]
}

resource "azurerm_subnet" "subnet" {
  name = "app-subnet"
  resource_group_name = azurerm_resource_group.provisioner-vm.name
  virtual_network_name = azurerm_virtual_network.provioner-vnet.name
  address_prefixes = [ "10.100.0.0/26" ]
  depends_on = [ azurerm_virtual_network.provioner-vnet ]
}

resource "azurerm_public_ip" "pip" {
  name = "gethupip2023"
  resource_group_name = azurerm_resource_group.provisioner-vm.name
  location = "eastus"
  allocation_method = "Dynamic"
  sku = "Basic"
  depends_on = [ azurerm_resource_group.provisioner-vm ]
}

resource "azurerm_network_interface" "nic" {
  name = "mynic"
  resource_group_name = azurerm_resource_group.provisioner-vm.name
  location = azurerm_resource_group.provisioner-vm.location
  ip_configuration {
    name = "internal"
    private_ip_address_allocation = "Dynamic"
    subnet_id = azurerm_subnet.subnet.id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
  depends_on = [ azurerm_public_ip.pip, azurerm_subnet.subnet ]
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = "example-machine"
  resource_group_name = azurerm_resource_group.provisioner-vm.name
  location            = azurerm_resource_group.provisioner-vm.location
  size                = "Standard_D2S_v4"
  admin_username      = "adminuser"
  admin_password      = "P@$$w0rd1234!"
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }

  provisioner "local-exec" {
    command = "echo ${azurerm_public_ip.pip.id} >> pip-id.txt"
  }
}