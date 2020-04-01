# Creation of our Spokes Infrastructure

Our spoke will contain:
- An Application gateway acting as a WAF, sitting within its own subnet that routes traffic to our website
- A Website running on App Service accessible via a private link only
- An API running on App Service accessible via a private link only
- A Cosmos DB accessible via a private link only

## Creating the compontents with Terraform locally

> TODO - info on the terraform bootstraping 

...

## Deploying the components via an automated pipeline

...
