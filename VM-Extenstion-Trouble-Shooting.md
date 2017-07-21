Trying to run the MSI VM Extension on a VM and running into issues? Check below to see if your issue is listed and what can fix it. 
We also monitor ``//stackoverflow tag azuremsi``, check there to see if someone else has run into your issue

## VM Extension deployment failing with error code 1009
### Issue: The following is seen during MSI VM Extension deployment:
```
{ "status": "Failed", "error": { "code": "ResourceDeploymentFailure", "message": "The resource operation completed with terminal provisioning state 'Failed'.", "details": [ { "code": "VMExtensionHandlerNonTransientError", "message": "Handler 'Microsoft.ManagedIdentity.ManagedIdentityExtensionForWindows' has reported failure for VM Extension 'ManagedIdentityExtensionForWindows' with terminal error code '1009' and error message: 'Enable failed for plugin (name: Microsoft.ManagedIdentity.ManagedIdentityExtensionForWindows, version 1.0.0.1) with exception Command C:\\Packages\\Plugins\\Microsoft.ManagedIdentity.ManagedIdentityExtensionForWindows\\1.0.0.1\\msi-extension-handler.exe of Microsoft.ManagedIdentity.ManagedIdentityExtensionForWindows has exited with Exit code: 1'" } ] } }
```
**Root Cause 1:** VM did not have an identity created for it during deployment so the MSI VM Extension fails to deploy and run properly.  
**Resolution 1:** Make sure the ARM template used specifies using an MSI identity for the VM. The "Microsoft.Compute/virtualMachines" resource definition in the template should contain the following:
```
"identity": { 
   "type": "systemAssigned"
}
```

**Root Cause 2:** Template did not have "settings" property defined for the VM extension. 
"C:\WindowsAzure\Logs\Plugins\Microsoft.ManagedIdentity.ManagedIdentityExtensionForWindows\1.0.0.1\msixtn-handler-0.log" on the VM will have the following entry:
```
[MSIXTN-HANDLER-0.9.0-beta]2017/07/05 23:24:30 ERROR: The sequence number of enable operation can't be discovered. Can't find out seqnum from C:\Packages\Plugins\Microsoft.ManagedIdentity.ManagedIdentityExtensionForWindows\1.0.0.1\RuntimeSettings, not enough files. 
```

**Resolution 2:** Ensure the template defines the "settings" property with a defined port for the VM Extension such as:
  ```
  {
        "type": "Microsoft.Compute/virtualMachines/extensions",
        "name": "[concat(parameters('vmName'),'/ManagedIdentityExtensionForWindows')]",
        "apiVersion": "2015-05-01-preview",
        "location": "[resourceGroup().location]",
        "dependsOn": [
            "[concat('Microsoft.Compute/virtualMachines/', parameters('vmName'))]"
        ],
        "properties": {
            "publisher": "Microsoft.ManagedIdentity",
            "type": "ManagedIdentityExtensionForWindows",
            "typeHandlerVersion": "1.0",
            "autoUpgradeMinorVersion": true,
            "settings": {
                "port": 50342
            }
        }
    }
```
**Root Cause 3:** Template did not specify the port within settings. Similar to Root Cause 2, except settings did not include the port property. 
"C:\WindowsAzure\Logs\Plugins\Microsoft.ManagedIdentity.ManagedIdentityExtensionForWindows\1.0.0.1\msixtn-handler-0.log" will show (among other errors):
```
[MSIXTN-HANDLER-0.9.0-beta]2017/07/06 02:38:17 FATAL: The Azure Managed Identity extension handler completed with error. The extension handler failed to run the webservice[http://localhost:0] powered by C:\Packages\Plugins\Microsoft.ManagedIdentity.ManagedIdentityExtensionForWindows\1.0.0.1\msi-extension.exe. Unable to read service url discovery document C:\WindowsAzure\Config\ManagedIdentity-Settings. open C:\WindowsAzure\Config\ManagedIdentity-Settings: The system cannot find the file specified.
```

**Resolution 3:** Same as Resolution 2, ensure settings and port are defined.

## VM Extension does not use the port that was configured in the settings
### Issue: A port was specified in the template for the VM Extension and, once deployed, the VM Extension is not using that port.
**Root Cause:** The VM Extension will fail to parse the settings if "protectedSettings" is specified.  
**Resolution:** Remove "protectedSettings" from the template. For example, given:
```
    {
        "type": "Microsoft.Compute/virtualMachines/extensions",
        "name": "[concat(parameters('vmName'),'/ManagedIdentityExtensionForWindows')]",
        "apiVersion": "2015-05-01-preview",
        "location": "[resourceGroup().location]",
        "dependsOn": [
            "[concat('Microsoft.Compute/virtualMachines/', parameters('vmName'))]"
        ],
        "properties": {
            "publisher": "Microsoft.ManagedIdentity",
            "type": "ManagedIdentityExtensionForWindows",
            "typeHandlerVersion": "1.0",
            "autoUpgradeMinorVersion": true,
            "settings": {
                "port": 51234
            },
            "protectedSettings": { }
        }
    }
```

Remove the "protectedSettings" property:
```
    {
        "type": "Microsoft.Compute/virtualMachines/extensions",
        "name": "[concat(parameters('vmName'),'/ManagedIdentityExtensionForWindows')]",
        "apiVersion": "2015-05-01-preview",
        "location": "[resourceGroup().location]",
        "dependsOn": [
            "[concat('Microsoft.Compute/virtualMachines/', parameters('vmName'))]"
        ],
        "properties": {
            "publisher": "Microsoft.ManagedIdentity",
            "type": "ManagedIdentityExtensionForWindows",
            "typeHandlerVersion": "1.0",
            "autoUpgradeMinorVersion": true,
            "settings": {
                "port": 51234
            }
        }
    }
```

