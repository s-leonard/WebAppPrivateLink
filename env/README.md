# Run Terraform Locally

If you have ran the Bootstrap commands you should have two files.  

```
env/local/backend.tf
env/local/terraform.tfvars
```

These files have been added to the ```.gitignore``` file so you dont have to worry about the keys being pushed into source control. 


## Build the Kubernetes Cluster

The following scripts will build the kubernetes cluster. Terraform will use a remote Azure blob storage state file as defined in ```env/local/backend.tf``` and referened in the below init command. 

It will also create these resouces using a service principal. The credentials for this are stored in ```env/local/terraform.tfvars``` and referenced in the azurerm and azuread providers in ```env/main.tf```

```
terraform init -backend-config="local/backend.tf" 

terraform plan -target azurerm_app_service.website -var-file="local/terraform.tfvars"

terraform apply -target azurerm_app_service.website -var-file="local/terraform.tfvars"

terraform plan -var-file="local/terraform.tfvars"

terraform apply -var-file="local/terraform.tfvars"
```

Once terraform apply has finised you can extract the kubernetes config from the outputs and save it to disc in a file which is also ignored my source control. 

```
bash extract_kube_config.sh
```

## Accessing the Kubernetes cluster

```
kubectl create namespace dev --kubeconfig .kubeconfig
kubectl create namespace uat --kubeconfig .kubeconfig
kubectl create namespace preprod --kubeconfig .kubeconfig
kubectl get nodes --kubeconfig .kubeconfig
```
