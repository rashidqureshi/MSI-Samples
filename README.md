
# Introduction
The Managed Service Identity scenarios enables an Azure VM to autonomously, using its own managed identity, to directly authenticate and interact with other Azure services using short-lived bearer tokens.  The lifecycle of this identity is tied to the overall lifecycle of the VM itself.

The samples included here show following:
1. Deploy an Azure VM with managed identity
2. Authorize the VM's identity for access to ARM resources
3. Get a token using the managed identity
4. Call the control plane (ARM) using the token to perform management operations upon resources within Azure

The Managed Service Identity infrastructure is presently deployed in all public Azure regions. To use this infrastructure your VM will need to be created in one of the public regions. 

## Deploy VM with managed identity
Add identity attribute and MSI Extension to the VM at deployment time as a dependency within your ARM template:
```
    {
        "apiVersion": "2015-06-15",
        "type": "Microsoft.Compute/virtualMachines",
        ...
        "identity": { 
            "type": "systemAssigned"
        },
        ...
    }
```
```
    { 
        "type": "Microsoft.Compute/virtualMachines/extensions",
        "name": "[concat(variables('vmName'),'/ManagedIdentityExtensionForLinux')]",
        "apiVersion": "2016-03-30",
        "location": "[resourceGroup().location]",
        "dependsOn": [
            "[concat('Microsoft.Compute/virtualMachines/', variables('vmName'))]",
            "[concat('Microsoft.Authorization/roleAssignments/', variables('roleAssignmentId'))]"
        ],
        "properties": {
            "publisher": "Microsoft.ManagedIdentity",
            "type": "ManagedIdentityExtensionForLinux",
            "typeHandlerVersion": "1.0",
            "autoUpgradeMinorVersion": true,
            "settings": {
                "port": 50343
            },
            "protectedSettings": {}
        }
    } 
```
•	The default port is 50343.  You can configure a different port at deployment time within the Properties section above:
```
        "properties": {
           "publisher": "Microsoft.ManagedIdentity",
           "autoUpgradeMinorVersion": true,
           "settings": {
                "port": 50342
          },
```
## Authorize the VM's identity for access to ARM resources

```
    {
       "apiVersion": "2016-07-01",
       "type": "Microsoft.Authorization/roleAssignments",
       "name": "[variables('roleAssignmentId')]",
       "dependsOn": [
                    "[concat('Microsoft.Compute/virtualMachines/', variables('vmName'))]"
        ],
        "properties": {
           "roleDefinitionId": "[variables('contributorRoleDefinitionId')]",
           "principalId": "[reference(concat('Microsoft.Compute/virtualMachines/', variables('vmName')), '2017-03-30', 'Full').identity.principalId]"
                }
    },
```
## Get a token using the managed identity
Read from http://localhost:50343/oauth2/token to fetch AAD token. Following shows how it can be done in the template
```
 "outputs": {
        "commandToGetAToken":{
            "type": "string",
            "value": "[concat('curl --data \"authority=https://login.microsoftonline.com/', reference(concat('Microsoft.Compute/virtualMachines/', variables('vmName')), '2017-03-30', 'Full').identity.tenantId, '&&resource=https://management.azure.com\" http://localhost:50343/oauth2/token')]"
        }
    }
```
## Call the control plane (ARM) using the token to perform management operations upon resources within Azure
Using PS to perform GET/PUT REST operations upon the ARM Resource Group ([as documented here](https://docs.microsoft.com/en-us/rest/api/)):

```
    PUT /subscriptions/<SubID>/resourcegroups/ExampleResourceGroup?api-version=2016-02-01  HTTP/1.1
    Authorization: Bearer <bearer-token from MSI localhost fetch>
    Content-Length: 29
    Content-Type: application/json
    Host: management.azure.com

    {
      "location": "West US"
    }
```

