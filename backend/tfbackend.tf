resource "azurerm_resource_group" "rstf" {
  name                = "rg-terraform-backend"
  location            = "UK South"
  tags                = {Environment = "demo"}
}

resource "azurerm_storage_account" "rstf" {
  name                     = "sarstfbackend666"
  resource_group_name      = azurerm_resource_group.rstf.name
  location                 = azurerm_resource_group.rstf.location
  account_kind             = "StorageV2"
  account_tier             = "Standard"
  account_replication_type = "RAGRS"
}

resource "azurerm_storage_container" "rstf" {
  name                     = "integrationservices"
  storage_account_name     = azurerm_storage_account.rstf.name
  container_access_type    = "private"
}