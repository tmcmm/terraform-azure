provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you are using version 1.x, the "features" block is not allowed.
    version = "~>2.0"
    features {}
}

# Use Azure storage account for terraform state
terraform {
    required_version = ">= 0.12"
    backend "azurerm" {
      resource_group_name  = "Your_rosource_group"
      storage_account_name = "terraformtmcmm"
      container_name       = "tfstate"
      access_key = ".....="
    }
}