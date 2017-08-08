Azure Managed Identity service enables Azure resources to gain an identity represented by AAD service principal. This enables a resource to access other Azure resources by presenting an AAD token, representing the AAD service principal, to the target resource that accepts AAD authentication flow.

The Managed Identity service will take additional responsibility of rotating the certs associated with service principal so the user does not to be aware of or manage the certificate associated with service principal.

For a VM resource, the Managed service identity also installs an extension on the VM. This extension provides a restful endpoint for an App to acquire a bearer token that the app can use to authenticate itself with other resources.

This article shows you how to use the Managed service identity extension to:
1.	Acquire a token
2.	Access Azure resource manager using the token to list resources

