resource "azurerm_resource_group" "k8s" {
    name     = "${var.prefix}-rg"
    location = var.location
}

# AKS Cluster Network
module "aks_network" {
  source              = "../modules/aks_network"
  subnet_name         = "${var.subnet_name}"
  vnet_name           = "${var.vnet_name}"
  resource_group_name = azurerm_resource_group.k8s.name
  subnet_cidr         = "${var.snetaddress_space}"
  location            = var.location
  address_space       = "${var.vnet_address_space}"
}

module "log_analytics" {
  source                           = "../modules/log_analytics"
  resource_group_name              = azurerm_resource_group.k8s.name
  log_analytics_workspace_location = var.log_analytics_workspace_location
  log_analytics_workspace_name     = var.log_analytics_workspace_name
  log_analytics_workspace_sku      = var.log_analytics_workspace_sku
}

# AKS Cluster
module "aks_cluster" {
  source                   = "../modules/aks-cluster"
  cluster_name             = "${var.prefix}-cluster"
  location                 = azurerm_resource_group.k8s.location
  dns_prefix               = "${var.prefix}"
  resource_group_name      = azurerm_resource_group.k8s.name
  kubernetes_version       = "${var.kubernetes_version}"
  vnet_subnet_id           = module.aks_network.aks_subnet_id
  client_id                = var.client_id
  client_secret            = var.client_secret
  diagnostics_workspace_id = module.log_analytics.azurerm_log_analytics_workspace
  min_count                = var.min_count
  max_count                = var.max_count
  node_count               = var.node_count
  vm_size                  = var.vm_size
  os_disk_size_gb          = "128"
  max_pods                 = "110"
  
  additional_node_pools = {
    usernpool = {
      name = "usernpool"
      zones = null
      taints = null
      node_count = 2
      node_os = "Linux"
      vm_size = "Standard_D2s_v3"
      mode = "User"
      enable_auto_scaling = true
      enable_node_public_ip = false
      min_count = 1
      max_count = 5
      max_pods  = 100
      os_disk_size_gb = 128
      agent_pool_type = "VirtualMachineScaleSets"
    }
  }
}

resource "azurerm_container_registry" "acr" {
  name                     = var.container_registry_name
  resource_group_name      = azurerm_resource_group.k8s.name
  location                 = azurerm_resource_group.k8s.location
  sku                      = "Premium"
  admin_enabled            = false
}

resource "azurerm_role_assignment" "aks_sp_container_registry" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id         = var.client_id
  skip_service_principal_aad_check = true
}

provider "kubernetes" {
  host                   = module.aks_cluster.host
  client_certificate     = base64decode(module.aks_cluster.client_certificate)
  client_key             = base64decode(module.aks_cluster.client_key)
  cluster_ca_certificate = base64decode(module.aks_cluster.cluster_ca_certificate)
  #host                   = module.aks_cluster.output.azurerm_kubernetes_cluster_host
  #client_certificate     = module.aks_cluster.output.azurerm_kubernetes_cluster_client_certificate
  #client_key             = module.aks_cluster.output.azurerm_kubernetes_cluster_client_key
  #cluster_ca_certificate = module.aks_cluster.output.azurerm_kubernetes_cluster_cluster_ca_certificate
}

resource "kubernetes_deployment" "nginx" {
  metadata {
    name = "nginx-example"
    labels = {
      App = "NginxExample"
    }
  }

  spec {
    replicas = 2
    selector {
      match_labels = {
        App = "NginxExample"
      }
    }
    template {
      metadata {
        labels = {
          App = "NginxExample"
        }
      }
      spec {
        container {
          image = "nginx:latest"
          name  = "example"

          port {
            container_port = 80
          }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }
      } 
    }
  }
}
resource "kubernetes_service" "nginx" {
  metadata {
    name = "nginx-example"
  }
  spec {
    selector = {
      App = kubernetes_deployment.nginx.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
  }
}