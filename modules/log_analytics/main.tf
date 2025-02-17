resource "azurerm_log_analytics_workspace" "workspace" {
  name                = var.workspace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku
  retention_in_days   = var.retention_in_days

  tags = {
    Environment = "Test"
    Managed_By  = "Terraform"
  }
}


resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "Solution(${azurerm_log_analytics_workspace.workspace.name})"
  location              = azurerm_log_analytics_workspace.workspace.location
  resource_group_name   = azurerm_log_analytics_workspace.workspace.resource_group_name
  workspace_name        = azurerm_log_analytics_workspace.workspace.name
  workspace_resource_id = azurerm_log_analytics_workspace.workspace.id

  plan {
    publisher = "Microsoft"
    product   = "ContainerInsights"
  }
}