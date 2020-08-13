
###########################################
# Global Variables
###########################################
LOCATION=centralus
PREFIX=WS$(date +%s%N | md5sum | cut -c1-6)


###########################################
# Hub & Spoke Networks
###########################################

RG_HUB=hub
RG_SPOKE_DEV=devspoke
RG_SPOKE_PROD=prodspoke
VNET_HUB=hubvnet
VNET_SPOKE_DEV=devvnet
VNET_SPOKE_PROD=prodvnet

VNET_HUB_IPRANGE=10.0.0.0/16
VNET_SPOKE_IPRANGE=10.1.0.0/16
VNET_SPOKE_PROD_IPRANGE=10.2.0.0/16

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
API_SUBNET_IPRANGE_PROD=10.1.2.0/24

#FIREWALL_SUBNET=firewall
#FIREWALL_SUBNET_IPRANGE=10.0.0.0/24

HUB_TO_SPOKE_VNET_PEER_DEV=$(echo $PREFIX)-hub-spoke-peer-dev
SPOKE_TO_HUB_VNET_PEER_DEV=$(echo $PREFIX)-spoke-hub-peer-dev

HUB_TO_SPOKE_VNET_PEER_PROD=$(echo $PREFIX)-hub-spoke-peer-prod
SPOKE_TO_HUB_VNET_PEER_PROD=$(echo $PREFIX)-spoke-hub-peer-prod

az group create -n $RG_HUB -l $LOCATION
az group create -n $RG_SPOKE_DEV -l $LOCATION
az group create -n $RG_SPOKE_PROD -l $LOCATION

az network vnet create -n $VNET_HUB -g $RG_HUB --address-prefixes $VNET_HUB_IPRANGE
az network vnet create -n $VNET_SPOKE_DEV -g $RG_SPOKE --address-prefixes $VNET_SPOKE_IPRANGE
az network vnet create -n $VNET_SPOKE_PROD -g $RG_SPOKE --address-prefixes $VNET_SPOKE_PROD_IPRANGE

#Create the Subnets in each vnet
az network vnet subnet create -n $APPGATEWAY_SUBNET_DEV -g $RG_SPOKE_DEV --address-prefixes $APPGATEWAY_SUBNET_IPRANGE_DEV --vnet-name $VNET_SPOKE_DEV
az network vnet subnet create -n $APPGATEWAY_SUBNET_PROD -g $RG_SPOKE_PROD --address-prefixes $APPGATEWAY_SUBNET_IPRANGE_PROD --vnet-name $VNET_SPOKE_PROD

az network vnet subnet create -n $WEB_SUBNET_DEV -g $RG_SPOKE_DEV --address-prefixes $WEB_SUBNET_IPRANGE_DEV --vnet-name $VNET_SPOKE_DEV --service-endpoints "Microsoft.Web"
az network vnet subnet create -n $WEB_SUBNET_PROD -g $RG_SPOKE_PROD --address-prefixes $WEB_SUBNET_IPRANGE_PROD --vnet-name $VNET_SPOKE_PROD --service-endpoints "Microsoft.Web"
az network vnet subnet create -n $API_SUBNET_DEV -g $RG_SPOKE_DEV --address-prefixes $API_SUBNET_IPRANGE_DEV --vnet-name $VNET_SPOKE_DEV --service-endpoints "Microsoft.Web"
az network vnet subnet create -n $API_SUBNET_PROD -g $RG_SPOKE_PROD --address-prefixes $API_SUBNET_IPRANGE_PROD --vnet-name $VNET_SPOKE_PROD --service-endpoints "Microsoft.Web"

#az network vnet subnet create -n $FIREWALL_SUBNET -g $RG_HUB --address-prefixes $FIREWALL_SUBNET_IPRANGE --vnet-name $VNET_HUB

#Peer the Vnets
HUBID=$(az network vnet show -g $RG_HUB -n $VNET_HUB --query id -o tsv)
SPOKEID_DEV=$(az network vnet show -g $RG_SPOKE -n $VNET_SPOKE --query id -o tsv)
SPOKEID_PROD=$(az network vnet show -g $RG_SPOKE -n $VNET_SPOKE --query id -o tsv)

az network vnet peering create -g $RG_HUB -n $HUB_TO_SPOKE_VNET_PEER_DEV --vnet-name $VNET_HUB --remote-vnet $SPOKEID_DEV --allow-vnet-access
az network vnet peering create -g $RG_HUB -n $HUB_TO_SPOKE_VNET_PEER_DEV --vnet-name $VNET_HUB --remote-vnet $SPOKEID_PROD --allow-vnet-access

az network vnet peering create -g $RG_SPOKE -n $SPOKE_TO_HUB_VNET_PEER_DEV --vnet-name $VNET_SPOKE_DEV --remote-vnet $HUBID --allow-vnet-access
az network vnet peering create -g $RG_SPOKE -n $SPOKE_TO_HUB_VNET_PEER_PROD --vnet-name $VNET_SPOKE_PROD --remote-vnet $HUBID --allow-vnet-access

###########################################
# Hub Network
###########################################

RG_HUB="hub"
VNET_HUB="hub"

## Hub VNet
az network vnet create -n $VNET_HUB -g $RG_HUB --address-prefixes 10.0.0.0/16


## Firewall

az network vnet subnet create -n $FIREWALL_SUBNET -g $RG_HUB \
    --address-prefixes 10.0.0.0/24 --vnet-name $VNET_HUB

## Azure Deplopyment Agent



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

