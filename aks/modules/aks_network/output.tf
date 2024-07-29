
output name {
  description = "Specifies the name of the virtual network"
  value       = azurerm_virtual_network.aks_vnet.name
}

output aks_vnet_id {
  description = "Specifies the resource id of the virtual network"
  value       = azurerm_virtual_network.aks_vnet.id
}

output aks_subnet_id {
 description = "Contains a list of the the resource id of the subnets"
  value       = { for subnet in azurerm_subnet.aks_subnet : subnet.name => subnet.id }
}