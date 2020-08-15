
## Pre-Req
az extension add --name azure-firewall

###########################################
# Global Variables
###########################################
LOCATION=centralus
PREFIX=ws$(date +%s%N | md5sum | cut -c1-6)
SUBID=$(az account list --query "[?isDefault].id" -o tsv)
ADO_ACCOUNTNAME={AzureDevOps Account name}
ADO_PERSONALACCESSTOKEN={AzureDevOps personal access token}
ADO_VMADMINUSER=adminuser
ADO_VMADMINPASSWORD={ADO Agent VM admin password}

###########################################
# Hub & Spoke Networks
###########################################

RG_DEVOPSAGENT=devopsagent
RG_HUB=hub
RG_SPOKE_DEV=devspoke
RG_SPOKE_PROD=prodspoke
VNET_HUB=hubvnet
VNET_SPOKE_DEV=devvnet
VNET_SPOKE_PROD=prodvnet

VNET_HUB_IPRANGE=10.0.0.0/16
VNET_SPOKE_IPRANGE_DEV=10.1.0.0/16
VNET_SPOKE_IPRANGE_PROD=10.2.0.0/16

APPGATEWAY_SUBNET_DEV=appgatewaydev
APPGATEWAY_SUBNET_PROD=appgatewayprod
APPGATEWAY_SUBNET_IPRANGE_DEV=10.1.0.0/24
APPGATEWAY_SUBNET_IPRANGE_PROD=10.2.0.0/24

WEB_SUBNET_DEV=webdev
WEB_SUBNET_PROD=webprod
WEB_SUBNET_IPRANGE_DEV=10.1.1.0/24
WEB_SUBNET_IPRANGE_PROD=10.2.1.0/24

API_SUBNET_DEV=apidev
API_SUBNET_PROD=apiprod
API_SUBNET_IPRANGE_DEV=10.1.2.0/24
API_SUBNET_IPRANGE_PROD=10.2.2.0/24

#Firewall subnet MUST be named AzureFirewallSubnet
FIREWALL_SUBNET=AzureFirewallSubnet
FIREWALL_SUBNET_IPRANGE=10.0.0.0/24

HUB_TO_SPOKE_VNET_PEER_DEV=$(echo $PREFIX)-hub-spoke-peer-dev
SPOKE_TO_HUB_VNET_PEER_DEV=$(echo $PREFIX)-spoke-hub-peer-dev

HUB_TO_SPOKE_VNET_PEER_PROD=$(echo $PREFIX)-hub-spoke-peer-prod
SPOKE_TO_HUB_VNET_PEER_PROD=$(echo $PREFIX)-spoke-hub-peer-prod

az group create -n $RG_HUB -l $LOCATION
az group create -n $RG_SPOKE_DEV -l $LOCATION
az group create -n $RG_SPOKE_PROD -l $LOCATION

az network vnet create -n $VNET_HUB -g $RG_HUB --address-prefixes $VNET_HUB_IPRANGE
az network vnet create -n $VNET_SPOKE_DEV -g $RG_SPOKE_DEV --address-prefixes $VNET_SPOKE_IPRANGE_DEV
az network vnet create -n $VNET_SPOKE_PROD -g $RG_SPOKE_PROD --address-prefixes $VNET_SPOKE_IPRANGE_PROD

#Create the Subnets in each vnet
az network vnet subnet create -n $APPGATEWAY_SUBNET_DEV -g $RG_SPOKE_DEV --address-prefixes $APPGATEWAY_SUBNET_IPRANGE_DEV --vnet-name $VNET_SPOKE_DEV
az network vnet subnet create -n $APPGATEWAY_SUBNET_PROD -g $RG_SPOKE_PROD --address-prefixes $APPGATEWAY_SUBNET_IPRANGE_PROD --vnet-name $VNET_SPOKE_PROD

az network vnet subnet create -n $WEB_SUBNET_DEV -g $RG_SPOKE_DEV --address-prefixes $WEB_SUBNET_IPRANGE_DEV --vnet-name $VNET_SPOKE_DEV --service-endpoints "Microsoft.Web"
az network vnet subnet create -n $WEB_SUBNET_PROD -g $RG_SPOKE_PROD --address-prefixes $WEB_SUBNET_IPRANGE_PROD --vnet-name $VNET_SPOKE_PROD --service-endpoints "Microsoft.Web"
az network vnet subnet create -n $API_SUBNET_DEV -g $RG_SPOKE_DEV --address-prefixes $API_SUBNET_IPRANGE_DEV --vnet-name $VNET_SPOKE_DEV --service-endpoints "Microsoft.Web"
az network vnet subnet create -n $API_SUBNET_PROD -g $RG_SPOKE_PROD --address-prefixes $API_SUBNET_IPRANGE_PROD --vnet-name $VNET_SPOKE_PROD --service-endpoints "Microsoft.Web"

az network vnet subnet create -n $FIREWALL_SUBNET -g $RG_HUB --address-prefixes $FIREWALL_SUBNET_IPRANGE --vnet-name $VNET_HUB

#Peer the Vnets
HUBID=$(az network vnet show -g $RG_HUB -n $VNET_HUB --query id -o tsv)
SPOKEID_DEV=$(az network vnet show -g $RG_SPOKE_DEV -n $VNET_SPOKE_DEV --query id -o tsv)
SPOKEID_PROD=$(az network vnet show -g $RG_SPOKE_PROD -n $VNET_SPOKE_PROD --query id -o tsv)

az network vnet peering create -g $RG_HUB -n $HUB_TO_SPOKE_VNET_PEER_DEV --vnet-name $VNET_HUB --remote-vnet $SPOKEID_DEV --allow-vnet-access
az network vnet peering create -g $RG_HUB -n $HUB_TO_SPOKE_VNET_PEER_PROD --vnet-name $VNET_HUB --remote-vnet $SPOKEID_PROD --allow-vnet-access

az network vnet peering create -g $RG_SPOKE_DEV -n $SPOKE_TO_HUB_VNET_PEER_DEV --vnet-name $VNET_SPOKE_DEV --remote-vnet $HUBID --allow-vnet-access
az network vnet peering create -g $RG_SPOKE_PROD -n $SPOKE_TO_HUB_VNET_PEER_PROD --vnet-name $VNET_SPOKE_PROD --remote-vnet $HUBID --allow-vnet-access

###########################################
# Hub Network
###########################################
FWPUBLICIP_NAME=$(echo $PREFIX)-fw-ip
FWNAME=$(echo $PREFIX)-fw
FWROUTE_TABLE_NAME="${PREFIX}fwrt"
FWROUTE_NAME="${PREFIX}fwrn"
FWROUTE_NAME_INTERNET="${PREFIX}fwinternet"
FWIPCONFIG_NAME="${PREFIX}fwconfig"

## Firewall

az network public-ip create -g $RG_HUB -n $FWPUBLICIP_NAME -l $LOCATION --sku "Standard"

az network firewall create -g $RG_HUB -n $FWNAME -l $LOCATION

# Configure Firewall IP Config

az network firewall ip-config create \
    -g $RG_HUB \
    -f $FWNAME \
    -n $FWIPCONFIG_NAME \
    --public-ip-address $FWPUBLICIP_NAME \
    --vnet-name $VNET_HUB

# Capture Firewall IP Address for Later Use

FWPUBLIC_IP=$(az network public-ip show -g $RG_HUB -n $FWPUBLICIP_NAME --query "ipAddress" -o tsv)
FWPRIVATE_IP=$(az network firewall show -g $RG_HUB -n $FWNAME --query "ipConfigurations[0].privateIpAddress" -o tsv)

# Create UDR and add a route for the web subnet (spoke), this ensures all traffic from the web app goes through the firewall
az network route-table create -g $RG_SPOKE_DEV --name $FWROUTE_TABLE_NAME
az network route-table route create -g $RG_SPOKE_DEV --name $FWROUTE_NAME --route-table-name $FWROUTE_TABLE_NAME --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address $FWPRIVATE_IP --subscription $SUBID

az network route-table create -g $RG_SPOKE_PROD --name $FWROUTE_TABLE_NAME
az network route-table route create -g $RG_SPOKE_PROD --name $FWROUTE_NAME --route-table-name $FWROUTE_TABLE_NAME --address-prefix 0.0.0.0/0 --next-hop-type VirtualAppliance --next-hop-ip-address $FWPRIVATE_IP --subscription $SUBID


#Ensure all traffic to httpbin.org is allowed (highly locked down)
#az network firewall application-rule create \
#    --collection-name $FIREWALL_HTTPBIN_APPLICATION_RULE_COLLECTION \
#    --name $FIREWALL_HTTPBIN_APPLICATION_RULE \
#    --firewall-name $FWNAME \
#    -g $RG_HUB \
#    --protocols HTTP=80 HTTPS=443 \
#    --action Allow \
#    --priority 100 \
#    --target-fqdns "httpbin.org" \
#    --source-addresses "*"

#Add the UDR to the network
az network vnet subnet update -g $RG_SPOKE_DEV --vnet-name $VNET_SPOKE_DEV --name $WEB_SUBNET_DEV --route-table $FWROUTE_TABLE_NAME
az network vnet subnet update -g $RG_SPOKE_DEV --vnet-name $VNET_SPOKE_DEV --name $API_SUBNET_DEV --route-table $FWROUTE_TABLE_NAME
az network vnet subnet update -g $RG_SPOKE_PROD --vnet-name $VNET_SPOKE_PROD --name $WEB_SUBNET_PROD --route-table $FWROUTE_TABLE_NAME
az network vnet subnet update -g $RG_SPOKE_PROD --vnet-name $VNET_SPOKE_PROD --name $API_SUBNET_PROD --route-table $FWROUTE_TABLE_NAME

## Azure Deplopyment Agent
az group create --name $RG_DEVOPSAGENT --location $LOCATION
az deployment group create -g $RG_DEVOPSAGENT --name agentdeployment \
  --template-uri "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-vm-vsts-agent/azuredeploy.json" \
  --parameters  publicIPDnsName=$(echo $PREFIX)agent \
                _artifactsLocation="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/201-vm-vsts-agent/" \
                vmAdminUser=$ADO_VMADMINUSER \
                vmAdminPassword=$ADO_VMADMINPASSWORD \
                vmSize=Standard_D1_v2 \
                vstsAccount=$ADO_ACCOUNTNAME \
                vstsPersonalAccessToken=$ADO_PERSONALACCESSTOKEN \
                vstsAgentCount=1 \
                modules="{}" \
                vstsPoolName=Default

###########################################
# Pre-Prod Spoke
###########################################

## Spoke VNet

## Website App Service Subnet 

## WebSite App Service Plan / App Service

## Website App Service Private Link

## Website App Service VNet Integration (with UDRs)


## API App Service Subnet 

## API App Service Plan / App Service

## API App Service Private Link

## API App Service VNet Integration (with UDRs)


## App Gateway Subnet

## App Gateway

## KeyVault

## KeyVault Access Policies (Website and API)

## Keyvault Secrets 

## Website App Service - App Settings (including keyvault)

## Azure SQL

### Azure SQL Connectivity

