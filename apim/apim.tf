provider "azurerm" {
  version = "=1.44.0"
}

// Load resource group
data "azurerm_resource_group" "demo" {
  name                = "rg-is-demo"
}

output "resource_group_name" {
  value               = data.azurerm_resource_group.demo.name
}

resource "azurerm_api_management" "demo" {
  name                = "apim-is-demo"
  location            = data.azurerm_resource_group.demo.location
  resource_group_name = data.azurerm_resource_group.demo.name
  publisher_name      = "ISDemo"
  publisher_email     = "rusmith@microsoft.com"

  sku_name = "Developer_1"

}

resource "azurerm_api_management_api" "demo" {
  name                = var.la-is-demo-receive-name
  resource_group_name = data.azurerm_resource_group.demo.name
  api_management_name = azurerm_api_management.demo.name
  revision            = "1"
  display_name        = "${var.la-is-demo-receive-name} API"
  path                = "receive"
  protocols           = ["https"]

  service_url         = "https://prod-04.uksouth.logic.azure.com/workflows/cf88e266de1547139c55d8a9c44bac8b/triggers"
}

resource "azurerm_api_management_backend" "demo" {
  name                = "${var.la-is-demo-receive-name}-backend"
  resource_group_name = data.azurerm_resource_group.demo.name
  api_management_name = azurerm_api_management.demo.name
  protocol            = "http"
  url                 = azurerm_api_management_api.demo.service_url
  resource_id         = "https://management.azure.com/subscriptions/ca9ae6cf-2ab2-48d0-981d-c1030fd74a64/resourceGroups/rg-is-demo/providers/Microsoft.Logic/workflows/${var.la-is-demo-receive-name}"
}

resource "azurerm_api_management_api_operation" "demo" {
  operation_id        = "manual-invoke"
  api_name            = azurerm_api_management_api.demo.name
  api_management_name = azurerm_api_management.demo.name
  resource_group_name = data.azurerm_resource_group.demo.name
  display_name        = "manual-invoke"
  method              = "POST"
  url_template        = "/manual/paths/invoke"
  description         = "Trigger a run of the logic app"

  request {
    description       = "The request body"

    representation {
      content_type     = "application/json"
      /* schema_id       = "5da8757dbdac0d127808ef3a"
      type_name       = "request-manual" */
    }
  }

  response {
    status_code        = 200
    description        = "The Logic App Response."

     representation {
      content_type     = "application/json"
      /* schema_id       = "5da8757dbdac0d127808ef3a"
      type_name       = "ManualPathsInvokePost200ApplicationJsonResponse" */
    }
  }

  response {
    status_code        = 500
    description        = "The Logic App Failed Response."

     representation {
      content_type     = "application/json"
      /* schema_id       = "5da8757dbdac0d127808ef3a"
      type_name       = "ManualPathsInvokePost200ApplicationJsonResponse" */
    }
  }
}

resource "azurerm_api_management_api_operation_policy" "demo" {
  api_name            = azurerm_api_management_api_operation.demo.api_name
  api_management_name = azurerm_api_management_api_operation.demo.api_management_name
  resource_group_name = data.azurerm_resource_group.demo.name
  operation_id        = azurerm_api_management_api_operation.demo.operation_id

  xml_content = <<XML
<policies>
  <inbound>
    <base />
    <set-method id="apim-generated-policy">POST</set-method>
    <rewrite-uri id="apim-generated-policy" template="/manual/paths/invoke/?api-version=2016-06-01&amp;sp=/triggers/manual/run&amp;sv=1.0&amp;sig=${var.la-is-demo-receive-sig}" />
    <set-header id="apim-generated-policy" name="Ocp-Apim-Subscription-Key" exists-action="delete" />
    </inbound>
    <backend>
        <base />
    </backend>
    <outbound>
      <base />
    </outbound>
    <on-error>
      <base />
    </on-error>
  </policies>
XML

}