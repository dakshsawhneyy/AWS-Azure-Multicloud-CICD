resource "azurerm_resource_group" "main" {
  name     = var.resource_group_name
  location = var.azure_location
}

resource "azurerm_container_registry" "app" {
  name                = "multicloudrepo"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Basic"
  admin_enabled       = true
}

resource "azurerm_virtual_network" "main" {
  name                = "multicloud-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "internal" {
  name                 = "multicloud-subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create Azure NSG
resource "azurerm_network_security_group" "web_nsg" {
  name                = "multicloud-nsg"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  # Allow HTTP Rule
  security_rule {
    name                       = "HTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # Allow SSH Rule
  security_rule {
    name                       = "SSH"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_public_ip" "web_public_ip" {
  name                = "multicloud-public-ip"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  allocation_method   = "Static" # Or "Static" if required
}

resource "azurerm_network_interface" "web_nic" {
  name                = "multicloud-nic"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.web_public_ip.id
  }
}

resource "azurerm_network_interface_security_group_association" "web_nic_assoc" {
  network_interface_id      = azurerm_network_interface.web_nic.id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}

# Public Key
resource "azurerm_ssh_public_key" "vm_key" {
  name                = "multicloud-azure-key"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  # This uses a local key you already have. 
  # If you don't have one, run 'ssh-keygen -t rsa -b 4096' in your terminal first.
  public_key          = var.azure_vm_ssh_public_key
}

# Virtual Machine
resource "azurerm_virtual_machine" "web" {
  name                  = "terraform-multicloud-vm"
  location              = azurerm_resource_group.main.location
  resource_group_name   = azurerm_resource_group.main.name
  vm_size               = "Standard_B2ats_v2"
  network_interface_ids = [azurerm_network_interface.web_nic.id]

  storage_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  }

  storage_os_disk {
    name              = "myosdisk1"
    caching           = "ReadWrite"
    create_option     = "FromImage"
    managed_disk_type = "Standard_LRS"
  }

  os_profile {
    computer_name  = "hostname"
    admin_username = "azureuser"
  }

  # Link the generated Azure SSH key block here
  os_profile_linux_config {
    disable_password_authentication = true

    ssh_keys {
      path     = "/home/azureuser/.ssh/authorized_keys"
      key_data = azurerm_ssh_public_key.vm_key.public_key
    }
  }
}