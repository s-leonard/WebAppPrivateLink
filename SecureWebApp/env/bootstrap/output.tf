output "azure_subscription_service_principal_object_id" {
    value = azuread_service_principal.lab.object_id 
}

output "azure_subscription_id" {
    value = data.azurerm_client_config.lab.subscription_id
}

output "azure_subscription_client_id" {
    value = azuread_application.lab.application_id
}

output "azure_subscription_client_secret" {
    value = random_string.lab.result
}

output "azure_tenant_id" {
    value = data.azurerm_client_config.lab.tenant_id
}

output "resource_group_name" {
    value = azurerm_resource_group.lab.name
}

output "storage_account_name" {
    value = azurerm_storage_account.lab.name
}

output "container_name" {
    value = azurerm_storage_container.lab.name
}

output "access_key" {
    value = azurerm_storage_account.lab.primary_access_key
}

output "key" {
    value = "${var.app_name}${var.env_name}.tfstate"
}


