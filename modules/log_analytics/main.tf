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

locals {
  # "^(.*?)\\(" 패턴은 워크스페이스 이름의 첫 번째 '(' 이전 부분을 캡처합니다.
  workspace_matches = regexall("^(.*?)\\(", azurerm_log_analytics_workspace.workspace.name)
  base_workspace_name = length(local.workspace_matches) > 0 ? local.workspace_matches[0] : azurerm_log_analytics_workspace.workspace.name
}

resource "azurerm_log_analytics_solution" "container_insights" {
  solution_name         = "Solution(${local.base_workspace_name})"
  location              = azurerm_log_analytics_workspace.workspace.location
  resource_group_name   = azurerm_log_analytics_workspace.workspace.resource_group_name
  workspace_name        = azurerm_log_analytics_workspace.workspace.name
  workspace_resource_id = azurerm_log_analytics_workspace.workspace.id

  plan {
    publisher = "Microsoft"
    product   = "ContainerInsights"
  }
}