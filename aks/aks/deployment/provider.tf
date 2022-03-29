terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
#    backend "azurerm" {
#      resource_group_name  = "learnterraform"
#      storage_account_name = "terraformtmcmm"
#      container_name       = "tfstate"
#      access_key = "(...)"
#      key = "codelab.microsoft.tfstate" 
#    }

}

provider "azurerm" {
  subscription_id = var.subscription_id
  # Tenant Id for the terraform SP
  tenant_id       = var.tenant_id
  features {}
}
