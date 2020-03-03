terraform {
  required_version = ">= 0.12"
  backend "azurerm" {
    resource_group_name  = "rg-terraform-backend"
    storage_account_name = "sarstfbackend666"
    container_name       = "integrationservices"
    key                  = "terraform-rstf-demo-apim.tfstate"
  }
}