Azure Managed Identity service enables Azure resources to gain a secure identity represented by AAD service principal. This enables a resource to access other Azure resource by presenting an AAD token to the target resource that accepts AAD authentication flow. 
The Managed Identity service will take additional responsibility of rotating the certs associated with service principal so the user.
For a VM resource, the Managed service identity also installs an extension on the VM. This extension provides a restful endpoint for an App to acquire a bearer token that the app can use to authenticate itself with other resources.
This article shows you how to use the Managed service identity extension to:
a)	Acquire a token
b)	Access Azure resource manager using the token to list resources

