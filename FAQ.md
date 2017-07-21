Trying to run the MSI VM Extension on a VM and running into questions? Check below to see if your question is listed. We also monitor 
//stackoverflow tag azuremsi, check there to see if someone else has run into your question.

## How can I get ObjectId/TenantId/ClientId/AppId for the identity used by the MSI VM Extension?
The VM Extension does not currently surface this information in a supported way. We are looking into adding this functionality.

## Does the identity used by the MSI VM Extension support multi-tenant scenarios in AAD?
No, currently there is no support for multi-tenant scenarios with MSI identities.

## How can I install the MSI VM Extension on an existing VM?
1) Update the template to include MSI specific fields and resources
  •	identity must be declared on the VM resource
  •	The MSI VM extension resource must be added
2) Perform an incremental update (https://docs.microsoft.com/en-us/azure/azure-resource-manager/resource-group-template-deploy)

  •	New-AzureRmResourceGroupDeployment -ResourceGroupName <yourResourceGoup> -TemplateFile <yourTemplateFile>

## How can I remove the MSI VM Extension from a VM?
Note that you can only remove the VM Extension itself. You cannot remove the identity associated with the VM without deleting the VM entirely.
  •	Windows: Remove-AzureRmVMExtension -ResourceGroupName <resourceGroupName> -VMName <vmName> -Name ManagedIdentityExtensionForWindows
  •	Linux: Remove-AzureRmVMExtension -ResourceGroupName <resourceGroupName> -VMName <vmName> -Name ManagedIdentityExtensionForLinux

## Known issues:
1351242 VM Extension fails to install if settings aren't specified or don't include port
1351249 VM Extension fails with unhelpful logs and error if VM doesn't have an identity
1351144 VM Extension will fail to parse settings if protectedSettings is specified

