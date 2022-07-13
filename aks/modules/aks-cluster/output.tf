output "azurerm_kubernetes_cluster_id" {
  value = azurerm_kubernetes_cluster.k8s.id
}

output "azurerm_kubernetes_cluster_fqdn" {
  value = azurerm_kubernetes_cluster.k8s.fqdn
}

output "azurerm_kubernetes_cluster_node_resource_group" {
  value = azurerm_kubernetes_cluster.k8s.node_resource_group
}

output "client_key" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_key
}
output "client_certificate" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].client_certificate
}
output "cluster_ca_certificate" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].cluster_ca_certificate
}
output "host" {
  sensitive = true
  value     = azurerm_kubernetes_cluster.k8s.kube_config[0].host
}

