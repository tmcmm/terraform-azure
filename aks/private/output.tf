output "virtual_machine_name" {
  value = random_string.virtual_machine_name.result
}

/* output "virtual_machine_publicIps" {
  value = [for vm in module.virtual_machine : vm.public_ip]
}
 */

/* output "virtual_machine_publicIp" {
  value = flatten(module.virtual_machine.*.public_ip)
}
 */
 
output "virtual_machine_publicIp" {
  value = flatten([for vm in module.virtual_machine : vm.public_ip])
}

output "output_module_azurerm_kubernetes_cluster_id" {
  value = module.aks_cluster.azurerm_kubernetes_cluster_id
}

output "output_module_azurerm_kubernetes_cluster_fqdn" {
  value = module.aks_cluster.azurerm_kubernetes_cluster_fqdn
}

output "output_module_azurerm_kubernetes_cluster_node_resource_group" {
  value = module.aks_cluster.azurerm_kubernetes_cluster_node_resource_group
}

output "output_module_kubernetes_cluster_name" {
  value = module.aks_cluster.kubernetes_cluster_name
}

output "output_module_host" {
  value = module.aks_cluster.host
  sensitive = true
}

output "output_module_client_key" {
  value = module.aks_cluster.client_key
  sensitive = true
}

output "output_module_client_certificate" {
  value = module.aks_cluster.client_certificate
  sensitive = true
}

output "output_module_kube_config" {
  value     = module.aks_cluster.kube_config
  sensitive = true
}
output "output_module_cluster_ca_certificate" {
  value = module.aks_cluster.cluster_ca_certificate
  sensitive = true
}