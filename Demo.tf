terraform {
  
  /* required_version = ">= 0.12"
  backend "azurerm" { 
    resource_group_name  = "rg-terraform-backend"
    storage_account_name = "sarstfbackend666"
    container_name       = "integrationservices"
    key                  = "terraform-rstf-demo.tfstate" 
  } */
}
resource "azurerm_resource_group" "demo" {
  name                = "rg-is-demo"
  location            = "UK South"
  tags                = {Environment = "demo"}
}

/* Create Cosmos DB & SQL container */
resource "random_integer" "ri" {
  min = 10000
  max = 99999
}

resource "azurerm_cosmosdb_account" "demo" {
  name                = "cdba-is-demo-${random_integer.ri.result}"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  offer_type          = "Standard"
  kind                = "GlobalDocumentDB"

  enable_automatic_failover = true

  consistency_policy {
    consistency_level       = "BoundedStaleness"
    max_interval_in_seconds = 10
    max_staleness_prefix    = 200
  }  

  geo_location {
    prefix            = "cdba-is-demo-${random_integer.ri.result}-customid"
    location          = azurerm_resource_group.demo.location
    failover_priority = 0
  }
}

resource "azurerm_cosmosdb_sql_database" "demo" {
  name                = "ToDoList"
  resource_group_name = azurerm_cosmosdb_account.demo.resource_group_name
  account_name        = azurerm_cosmosdb_account.demo.name
  throughput          = 400
}

resource "azurerm_cosmosdb_sql_container" "demo" {
  name                = "Items"
  resource_group_name = azurerm_cosmosdb_account.demo.resource_group_name
  account_name        = azurerm_cosmosdb_account.demo.name
  database_name       = azurerm_cosmosdb_sql_database.demo.name
  partition_key_path  = "/_partitionKey"
  throughput          = 400

}

resource "azurerm_servicebus_namespace" "demo" {
  name                = "sb-is-demo-rgs"
  location            = azurerm_resource_group.demo.location
  resource_group_name = azurerm_resource_group.demo.name
  sku                 = "Standard"

  tags = {
    source = "terraform"
  }
}

/*
resource "azurerm_servicebus_namespace_authorization_rule" "demo" {
  name                = "RootManageSharedAccessKey"
  namespace_name      = azurerm_servicebus_namespace.demo.name
  resource_group_name = azurerm_resource_group.demo.name

  listen = true
  send   = true
  manage = false
}*/

output "sbconn" {
  value = azurerm_servicebus_namespace.demo.default_primary_connection_string
}

output "cosconn" {
    value = azurerm_cosmosdb_account.demo.primary_master_key 
}

resource "azurerm_servicebus_topic" "demo" {
  name                = "tp-is-demo-publish"
  resource_group_name = azurerm_resource_group.demo.name
  namespace_name      = azurerm_servicebus_namespace.demo.name

  enable_partitioning = true
}

resource "azurerm_servicebus_subscription" "demo-o" {
  name                = "subs-st-demo-outlook"
  resource_group_name = azurerm_resource_group.demo.name
  namespace_name      = azurerm_servicebus_namespace.demo.name
  topic_name          = azurerm_servicebus_topic.demo.name
  max_delivery_count  = 10
}

resource "azurerm_servicebus_subscription_rule" "demo-o" {
  name                = "tp-st-demo-publish"
  resource_group_name = azurerm_resource_group.demo.name
  namespace_name      = azurerm_servicebus_namespace.demo.name
  topic_name          = azurerm_servicebus_topic.demo.name
  subscription_name   = azurerm_servicebus_subscription.demo-o.name
  filter_type         = "SqlFilter"

  sql_filter          = "1=1"
}

resource "azurerm_servicebus_subscription" "demo-c" {
  name                = "subs-st-demo-cosmos"
  resource_group_name = azurerm_resource_group.demo.name
  namespace_name      = azurerm_servicebus_namespace.demo.name
  topic_name          = azurerm_servicebus_topic.demo.name
  max_delivery_count  = 10
}

resource "azurerm_servicebus_subscription_rule" "demo-c" {
  name                = "tp-st-demo-publish"
  resource_group_name = azurerm_resource_group.demo.name
  namespace_name      = azurerm_servicebus_namespace.demo.name
  topic_name          = azurerm_servicebus_topic.demo.name
  subscription_name   = azurerm_servicebus_subscription.demo-c.name
  filter_type         = "SqlFilter"

  sql_filter          = "1=1"
}

