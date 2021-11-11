resource "azurerm_virtual_network" "aks_vnet" {
  name                = var.vnet_name
  address_space       = [var.address_space]
  resource_group_name = var.resource_group_name
  location            = var.location
}
resource "azurerm_subnet" "aks_subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = azurerm_virtual_network.aks_vnet.name
  address_prefixes      = [var.subnet_cidr]
  service_endpoints    = ["Microsoft.Sql", "Microsoft.Storage", "Microsoft.KeyVault"]
}

# Security
#resource "azurerm_network_security_group" "nsg" {
#  name                = "aks-subnet-nsg"
#  location            = var.location
#  resource_group_name = var.resource_group_name
#}
#resource "azurerm_network_security_rule" "nsg-rule" {
#  name                        = "allow-port-22"
#  priority                    = 100
#  direction                   = "Inbound"
#  access                      = "Allow"
#  protocol                    = "Tcp"
#  source_port_range           = "*"
#  destination_port_range      = "*"
#  source_address_prefix       = "148.71.74.140"
#  destination_address_prefix  = "*"
#  resource_group_name         = var.resource_group_name
#  network_security_group_name = var.nsg_name
#}
#
## Link the subnet with the network securiy group
#resource "azurerm_subnet_network_security_group_association" "nsg_association" {
#  subnet_id                 = azurerm_subnet.aks_subnet.id
#  network_security_group_id = azurerm_network_security_group.nsg.id
#}




