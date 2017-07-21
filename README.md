# Introduction
The Managed Service Identity scenarios enables an Azure VM to autonomously, using its own managed identity, to directly authenticate and interact with other Azure services using short-lived bearer tokens.  The lifecycle of this identity is tied to the overall lifecycle of the VM itself.

The samples included here provide the capability to:
1. Deploy an Azure VM with managed identity
2. Get a token using the managed identity
3. Call the control plane (ARM) using the token to perform management operations upon resources within Azure.

The Managed Service Identity infrastructure is presently deployed in all public Azure regions. To use this infrastructure your VM will need to be created in one of the public regions. 

# Deploy VM with managed identity
Step 1: Add MSI Extension to the VM at deployment time as a dependency within your ARM template:
|{
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
        }|

