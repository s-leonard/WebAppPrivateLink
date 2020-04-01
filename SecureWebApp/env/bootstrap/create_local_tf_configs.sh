echo Creating local/terraform.tfvars
echo "azure_subscription_id=\"$(terraform output azure_subscription_id)\"" >>../local/terraform.tfvars
echo "azure_subscription_client_id=\"$(terraform output azure_subscription_client_id)\"" >>../local/terraform.tfvars
echo "azure_subscription_client_secret=\"$(terraform output azure_subscription_client_secret)\"" >>../local/terraform.tfvars
echo "azure_tenant_id=\"$(terraform output azure_tenant_id)\"" >>../local/terraform.tfvars
echo "azure_subscription_sp_object_id=\"$(terraform output azure_subscription_service_principal_object_id)\"" >>../local/terraform.tfvars

echo Creating local/backend.tf
echo "resource_group_name=\"$(terraform output resource_group_name)\"" >>../local/backend.tf
echo "storage_account_name=\"$(terraform output storage_account_name)\"" >>../local/backend.tf
echo "container_name=\"$(terraform output container_name)\"" >>../local/backend.tf
echo "access_key=\"$(terraform output access_key)\"" >>../local/backend.tf
echo "key=\"$(terraform output key)\"" >>../local/backend.tf