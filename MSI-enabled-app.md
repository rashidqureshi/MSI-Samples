
# Introduction
Azure Managed Identity service enables Azure resources to gain an identity represented by AAD service principal. This enables a source resource to access other Azure target resources by presenting an AAD token. The token represents the AAD service principal to the target resource which it would be able to authenticate with AAD. 

The Managed Identity service will take additional responsibility of rotating the certs associated with service principal so the user does not need to be aware of or manage the certificates associated with the service principals.

For a VM resource, the Managed service identity also installs an extension on the VM. This extension provides a restful endpoint for an App to acquire a bearer token that the app can use to authenticate itself with other resources.

This article shows you how to use the Managed service identity extension to:
1.	Acquire a token
2.	Access Azure resource manager using the token to list resources

## Before you get started:
1. Download the complete sample from [here](https://github.com/rashidqureshi/MSIApp/tree/master/MSISamples).
2. Download the template for deploying a VM with MSI from [here](https://github.com/rashidqureshi/MSI-Samples/blob/Add-Code-Sample/msi-windows-vm).

When you are ready, follow the procedures below

## Step 1: Deploy the VM using the template
a.	Sign in to the Azure using powershell  
      Login-AzureRMAccount
b.	Deploy the VM template using the PS cmd  
      PS cmd
c.	Assign VM identity read access to a resource group in your subscription  
      <PS> cmd
