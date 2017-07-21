# Introduction
The Managed Service Identity scenarios enables an Azure VM to autonomously, using its own managed identity, to directly authenticate and interact with other Azure services using short-lived bearer tokens.  The lifecycle of this identity is tied to the overall lifecycle of the VM itself.

This document describes the necessary sequence steps to enable an Azure VM to call the control plane (ARM) to perform management operations upon resources within Azure.

The Managed Service Identity infrastructure is presently deployed in all public Azure regions.  To use this infrastructure your VM will need to be created in one of the public regions. 

#Azure VM calling Azure Resource Manager using MSI
