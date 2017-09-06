# Introduction
Azure Managed Identity service enables Azure resources to gain an identity represented by AAD service principal. This enables a source resource to access other Azure target resources by presenting an AAD token. The token represents the AAD service principal to the target resource which it would be able to authenticate with AAD. 

The Managed Identity service will take additional responsibility of rotating the certs associated with service principal so the user does not need to be aware of or manage the certificates associated with the service principals.

For a VM resource, the Managed service identity also installs an extension on the VM. This extension provides a restful endpoint for an App to acquire a bearer token that the app can use to authenticate itself with other resources.

This article shows you how to use the Managed service identity extension to:
1.	Acquire a token
2.	Access Azure resource manager using the token to list resources

## Before you get started:
1. Download the complete sample from [here](https://github.com/rashidqureshi/MSIApp/tree/master/MSISamples).
2. Download the template for deploying a VM with MSI from [here](https://github.com/rashidqureshi/MSI-Samples/blob/master/msi-windows-vm).

When you are ready, follow the procedures below

## Step 1: Deploy VM using the template
1. Sign in to the Azure using powershell  
      a. ``` Login-AzureRMAccount ```
2. Deploy the VM template using the PS cmd  
      a. ``` New-AzureRmResourceGroup -Name myRG -Location "West US"```          
      b. ``` New-AzureRmResourceGroupDeployment -Name myDeployment -ResourceGroupName myRG -TemplateFile <template file.json> ```
3. Assign VM identity read access to the resource group in which the VM is created  
      a. ``` (Get-AzureRMVM -ResourceGroupName myRG -Name windowsvm0).identity.principalid ```  
      b. ``` New-AzureRmRoleAssignment -ObjectId <from above cmd> -RoleDefinitionName Reader -Scope /subscriptions/<subscriptionID>/resourceGroups/myRG ```

## Step 2: Set up the app to use Azure resource manager SDK
To begin, add the Azure resource manager sdk NuGet package to the project by using the Package Manager Console.  
 ``` PM> Install-Package Microsoft.Azure.Management.ResourceManager.Fluent ```

Compile the app to make sure there are no issues

Copy the project folder with binaries to the VM created in Step 1

## Step 3: Get the bearer token from the MSI extension
The code sample makes a local REST call to the MSI extension on the VM at port 50342. The REST call expects the resource URI. The resource URI specifies the target resource you want to access using the token. In the example the resource URI is for ARM (Azure Resource Manager): https://management.azure.com/. Furthermore the client need to specify a static header in the request "Metadata:true"

```
1.	public static void RunSample(string port, string subscriptionId) {  
2.	      
3.	    string address = 
4.	      string.Format("http://localhost:{0}/oauth2/token?resource={1}", port, 
5.	      Uri.EscapeDataString("https://management.azure.com/"));
6.	  
7.	    HttpWebRequest request = (HttpWebRequest) WebRequest.Create(address);  
8.         request.Headers.Add("Metadata","true"); 
9.	    StreamReader objReader = new StreamReader(request.GetResponse().GetResponseStream());  
10.	
11.	    var jss = new JavaScriptSerializer();  
12.	    var dict = jss.Deserialize <Dictionary<string, string>> (objReader.ReadLine());  
13.	
14.	    Write("Access token for ARM");   
15.	    Write(dict["access_token"]);
16.	 …… 
17.	}  

```

## Step 4 Instantiate the Azure resource manager SDK to list resources
In the previous step the code snippet shows how to get an access token from MSI extension to access Azure Resource Manager resource. 

The code below shows how to instantiate the Azure Resource Manager SDK with the token and list the resource groups the VM has been granted access to read.


```
1.	{ 
2.	…
3.	// Intialize SDK using the token  
4.	    var credentials = new TokenCredentials(dict["access_token"]);  
5.	    var resourceClient = new ResourceManagementClient(credentials);  
6.	    resourceClient.SubscriptionId = subscriptionId; 
7.	
8.	// List the resource group where VM has access to   
9.	    Write("Listing resource groups:");  
10.	    resourceClient.ResourceGroups.List().ToList().ForEach(rg => {  
11.	        Write("\tName: {0}, Id: {1}", rg.Name, rg.Id);  
12.	    });  
13.	…
14.	}  
```
Running the code will print myRG as the output
