output "azurerm_kubernetes_cluster_id" {
  value = azurerm_kubernetes_cluster.k8s.id
}

output "azurerm_kubernetes_cluster_fqdn" {
  value = azurerm_kubernetes_cluster.k8s.fqdn
}

output "azurerm_kubernetes_cluster_node_resource_group" {
  value = azurerm_kubernetes_cluster.k8s.node_resource_group
}
