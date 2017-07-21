#Requires -Version 5.0
[CmdletBinding()]   
param(
    # The subcription Id to log in to
    [Parameter(Mandatory=$true)]
    [string]
    $SubscriptionId,
    # The tenant Id to that contains the MSI
    [Parameter(Mandatory=$true)]
    [string]
    $TenantId
)

if (!(Get-PackageProvider -Name NuGet -ErrorAction SilentlyContinue -ListAvailable)) 
{
    Write-Verbose 'Installing nuget Package Provider'
    Install-PackageProvider -Name nuget -Force
}

Install-Module AzureRM.Profile -Force

$retry=0
$success=$false

# Get a token for ARM

$resource="https://management.azure.com/"
$postBody=@{authority="https://login.microsoftonline.com/$TenantId"; resource="$resource"}

# Retry till we can get a token, this is only needed until we can sequence extensions in VMSS

do
    {
        try
        {
           Write-Verbose "Getting Token Retry $retry"

           $reponse=Invoke-WebRequest -Uri http://localhost:50342/oauth2/token -Method POST -Body $postBody -UseBasicParsing
           $result=ConvertFrom-Json -InputObject $reponse.Content
           $success=$true
        }
        catch
        {
            Write-Verbose "Exception $_ trying to login"
            $retry++
            if ($retry -lt 5)
            {
                Write-Verbose 'Sleeeping for 60 seconds...'
                Start-Sleep 60
                Write-Verbose "Retrying attempt $retry"
            }
            else
            {
                throw $_
            }
        }
    }
while(!$success)

$retry=0
$success=$false

# Retry till we can find the subcription id in context , this is needed as the permission is set after the VM is created because the identity is not known until the VM is created 

do
    {
        try
        {

           Write-Verbose "Logging in Retry $retry"
           # Subscription will be null until permission is granted
           $loginResult=Login-AzureRmAccount -AccessToken $result.access_token -AccountId  $SubscriptionId
           if ($loginResult.Context.Subscription.Id -eq $SubscriptionId)
           {
                $success=$true
           }
           else 
           {
                throw "Subscription Id $SubscriptionId not in context"
           }

        }
        catch
        {
            Write-Verbose "Exception $_ trying to login"
            $retry++
            if ($retry -lt 5)
            {
                Write-Verbose 'Sleeeping for 60 seconds ...'
                Start-Sleep 60
                Write-Verbose "Retrying attempt $retry"
            }
            else
            {
                throw $_
            }
        }
    }
while(!$success)

New-AzureRmResourceGroup -Name "RG01" -Location "South Central US"
