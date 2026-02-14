# 1. Supplier definition
provider "azurerm"{
  features{}
}

# 2. Resource group
resource "azurerm_resource_group" "waf_project" {
  name     = "rg-waf-dvwa-project"
  location = "East US 2"
}

# 3. virtual network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-waf-project"
  resource_group_name = azurerm_resource_group.waf_project.name
  location            = azurerm_resource_group.waf_project.location
  address_space       = ["10.0.0.0/16"]
}

# 4. subnet for bastion
resource "azurerm_subnet" "bastion_Subnet" {
  name = "AzureBastionSubnet"
  resource_group_name = azurerm_resource_group.waf_project.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes = ["10.0.3.0/26"]

}
# 5. Subnet for WAF
resource "azurerm_subnet" "waf_subnet" {
  name                 = "snet-application-gateway"
  resource_group_name  = azurerm_resource_group.waf_project.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 6. Subnet for VM 
resource "azurerm_subnet" "backend_subnet" {
  name                 = "snet-backend-dvwa"
  resource_group_name  = azurerm_resource_group.waf_project.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

# 7. public ip bastion
resource "azurerm_public_ip" "pip_bastion" {
  name                = "pip_bastion"
  location            = azurerm_resource_group.waf_project.location
  resource_group_name = azurerm_resource_group.waf_project.name
  allocation_method   = "Static"
  sku                 = "Standard" 
}

# 8. bastion host
resource "azurerm_bastion_host" "bastion" {
  name                = "bastion"
  location            = azurerm_resource_group.waf_project.location 
  resource_group_name = azurerm_resource_group.waf_project.name

  ip_configuration {
    name                 = "configuration"
    subnet_id            = azurerm_subnet.bastion_Subnet.id      
    public_ip_address_id = azurerm_public_ip.pip_bastion.id     
  }
}
# 9. NIC
resource "azurerm_network_interface" "webaplication_nic" {
  name = "webaplication_nic"
  location = azurerm_resource_group.waf_project.location
  resource_group_name = azurerm_resource_group.waf_project.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.backend_subnet.id 
    private_ip_address_allocation = "Dynamic"
  }
}

# 10. vm
resource "azurerm_linux_virtual_machine" "webAplication_vm" {
  name = "WebAplicationVm"
  resource_group_name  = azurerm_resource_group.waf_project.name
  location = azurerm_resource_group.waf_project.location
  size = "Standard_B1s"
  
  admin_username = "dante"
  admin_password = "K19QTwjbXx"
  disable_password_authentication = false
  
  network_interface_ids = [
    azurerm_network_interface.webaplication_nic.id
  ]
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
}
 
# 11. public IP fot the WAF
resource "azurerm_public_ip" "waf_ip" {
  name                = "pip-waf-dvwa"
  resource_group_name = azurerm_resource_group.waf_project.name
  location            = azurerm_resource_group.waf_project.location
  allocation_method   = "Static"
  sku                 = "Standard" 
}

#gatway
resource "azurerm_application_gateway" "main" {
  name                = "waf-gateway"
  resource_group_name = azurerm_resource_group.waf_project.name
  location            = azurerm_resource_group.waf_project.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }

  gateway_ip_configuration {
    name      = "my-gateway-ip-configuration"
    subnet_id = azurerm_subnet.waf_subnet.id
  }

  frontend_port {
    name = "http_port"
    port = 80
  }

  frontend_ip_configuration {
    name                 = "my-frontend-ip"
    public_ip_address_id = azurerm_public_ip.waf_ip.id
  }

  backend_address_pool {
    name = "dvwa-backend-pool"
    # Aquí es donde ocurre la magia: apunta a la IP privada de tu NIC
    ip_addresses = [azurerm_network_interface.webaplication_nic.private_ip_address]
  }

  backend_http_settings {
    name                  = "http_settings"
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = "http_listener"
    frontend_ip_configuration_name = "my-frontend-ip"
    frontend_port_name             = "http_port"
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = "http_listener"
    backend_address_pool_name  = "dvwa-backend-pool"
    backend_http_settings_name = "http_settings"
    priority                   = 1
  }

  # CONFIGURACIÓN DEL WAF (El escudo)
  waf_configuration {
    enabled          = true
    firewall_mode    = "Prevention" # Cambia a "Detection" si solo quieres mirar
    rule_set_type    = "OWASP"
    rule_set_version = "3.2"
  }
}

