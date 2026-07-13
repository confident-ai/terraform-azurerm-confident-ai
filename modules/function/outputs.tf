output "function_name" {
  value = azurerm_linux_function_app.this.name
}

output "function_url" {
  description = "Helm codeExecutor.azure.functionUrl (append /api/execute)."
  value       = "https://${azurerm_linux_function_app.this.default_hostname}"
}
