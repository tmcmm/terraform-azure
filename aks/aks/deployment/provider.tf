terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
    backend "azurerm" {
      resource_group_name  = "learnterraform"
      storage_account_name = "terraformtmcmm"
      container_name       = "tfstate"
      access_key = "(...)"
      key = "codelab.microsoft.tfstate" 
    }

}

provider "azurerm" {
  subscription_id = "10dfa491-ff80-4d70-a4ee-9aeb49b8c00e"
  # Tenant Id for the terraform SP 'terraform-tmcmm'
  tenant_id       = "72f988bf-86f1-41af-91ab-2d7cd011db47"
  features {}
}

