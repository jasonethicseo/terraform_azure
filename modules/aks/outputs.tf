output "aks_id" {
  value = azurerm_kubernetes_cluster.aks.id
}

output "kube_config_raw" {
  value     = azurerm_kubernetes_cluster.aks.kube_config_raw
  sensitive = true
}

output "principal_id" {
  description = "Managed Identity Principal ID for the AKS cluster"
  value       = azurerm_kubernetes_cluster.aks.identity[0].principal_id
}
