# Configure the Azure provider
provider "azurerm" {
  features {}
}

# Create a resource group
resource "azurerm_resource_group" "bastion_rg" {
  name     = "bastion-resource-group"
  location = var.location
}

# Create a virtual network
resource "azurerm_virtual_network" "bastion_vnet" {
  name                = "bastion-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.bastion_rg.location
  resource_group_name = azurerm_resource_group.bastion_rg.name
}

# Create a subnet for the bastion host
resource "azurerm_subnet" "bastion_subnet" {
  name                 = "bastion-subnet"
  resource_group_name  = azurerm_resource_group.bastion_rg.name
  virtual_network_name = azurerm_virtual_network.bastion_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create a public IP for the bastion host
resource "azurerm_public_ip" "bastion_public_ip" {
  name                = "bastion-public-ip"
  location            = azurerm_resource_group.bastion_rg.location
  resource_group_name = azurerm_resource_group.bastion_rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# Create a network interface for the bastion host
resource "azurerm_network_interface" "bastion_nic" {
  name                = "bastion-nic"
  location            = azurerm_resource_group.bastion_rg.location
  resource_group_name = azurerm_resource_group.bastion_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.bastion_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.bastion_public_ip.id
  }
}

# Create a Linux virtual machine as the bastion host
resource "azurerm_linux_virtual_machine" "bastion_vm" {
  name                  = "bastion-host"
  location              = azurerm_resource_group.bastion_rg.location
  resource_group_name   = azurerm_resource_group.bastion_rg.name
  network_interface_ids = [azurerm_network_interface.bastion_nic.id]
  size                  = var.vm_size

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }

  computer_name                   = "bastion"
  admin_username                  = var.admin_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_username
    public_key = file(var.ssh_public_key_path)
  }
}

# Create a network security group
resource "azurerm_network_security_group" "bastion_nsg" {
  name                = "bastion-nsg"
  location            = azurerm_resource_group.bastion_rg.location
  resource_group_name = azurerm_resource_group.bastion_rg.name

  security_rule {
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix       = "*"
    destination_address_prefix  = "*"
  }
}

# Associate NSG with the network interface
resource "azurerm_network_interface_security_group_association" "bastion_nsg_association" {
  network_interface_id      = azurerm_network_interface.bastion_nic.id
  network_security_group_id = azurerm_network_security_group.bastion_nsg.id
}