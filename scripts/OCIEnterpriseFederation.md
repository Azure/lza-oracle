# Instructions for using the Entra Id PowerShell Accelerator Script for Azure and Oracle Cloud Infrastructure Federation

## Summary
The following document provides instructions for automating the creation of an Enterprise Application within Azure Entra Id for Federation with Oracle Cloud Infrastructure (OCI). By utilizing this solution accelerator, organizations can ensure a more consistent deployment experience, which is crucial for maintaining system integrity and reliability. This automation not only aims to eliminate potential errors that often occur during manual configuration but also seeks to expedite the implementation process. This process outlined in this document will only automate the Entra Id process and will not address OCI setup or configuration. The following two articles from Microsoft and Oracle document the step-by-step creation of federation between the two cloud platforms: [Tutorial: Microsoft Entra SSO integration with Oracle Cloud Infrastructure Console - Microsoft Entra ID | Microsoft Learn](https://learn.microsoft.com/en-us/entra/identity/saas-apps/oracle-cloud-tutorial) and [SSO Between OCI and Microsoft Azure](oracle.com).

## Audience
This document is intended primarily for IT planners, architects, and managers who are responsible for establishing and reviewing overall deployments and oversee operational practices. As a result, this guide emphasizes overall technical controls for implementation. It is assumed the person implementing the steps outlined in this guide has a basic understanding of identity and cloud concepts such as federation as it relates to both Azure and OCI. The person reading this script should have a basic understanding of operating a Windows 10 or 11 OS.
This document should also be made available for review to any program team members, affected business unit(s), infrastructure owners/managers, Information Security officer (ISO) and any client build team that are identified.  
The instructions presented in this guide must be implemented in the order as they are presented for a consistent result. 

## Assumptions
Before you begin, the following items are needed to complete this process successfully:
- Identity domain administrator role for the OCI IAM identity domain. See the following article from Oracle: [Understand administrator roles](Oracle documentation).
- An OCI account with the above mentioned roles to set up Single Sign-On (SSO).
- An Azure AD account with one of the following Azure AD roles:
  - Global Administrator
  - Cloud Application Administrator
  - Application Administrator
- Access to a Windows 10 or 11 OS for the execution of the script.

## Prerequisites
The following prerequisites are required to complete these steps successfully:
- A Microsoft Entra subscription.
- Oracle Cloud Infrastructure Console Single Sign-On (SSO) enabled subscription.
- OCI SSO has been configured first before configuring SSO on Entra. This is a hard requirement.
- Windows 10 or 11 OS with PowerShell installed.
- Access to both an Azure Subscription with Entra ID free, basic, P1, or P2 license.
- Access to an OCI Subscription.
- The OCI Service Provider metadata.xml file.
- Access to the OCIEnterpriseFederation.ps1 PowerShell script.
- Access to the OCI URL with the subscription Identifier: `https://idcs-<unique_ID>.identity.oraclecloud.com`.
- PowerShell 5.x installed on the Windows OS.
- The Windows 10 or 11 device can run PowerShell scripts unrestricted locally.
- The script can be executed directly from an administrative PowerShell on the Windows device or directly from the Windows PowerShell ISE.
- Both the PowerShell script and metadata.xml file should be placed within `C:\Temp`.
- Membership to either Global Administrator and Application Administrator within Entra Id.

## Benefits of Using the Script
The following will be achieved by executing the accelerator PowerShell script:
- Adding both the Azure AD and Graph PowerShell modules if not installed on the Windows device.
- The creation of an Entra Id Enterprise Application configured for SSO.
- Adding a user to the Enterprise application for testing.
- The creation of the following Entra Id Groups to match those within OCI:
  - odbaa-exa-infra-administrator
  - odbaa-vm-cluster-administrator
  - odbaa-db-family-administrators
  - odbaa-db-family-readers
  - odbaa-exa-cdb-administrators
  - odbaa-exa-pdb-administrators
  - odbaa-costmgmt-administrators
- Adding the specified user into the above-mentioned groups.

## Instructions
The following are the instructions for using the Accelerator PowerShell script with Entra Id.

### Procedure
1. Place the OCI metadata.xml and OCIEnterpriseFederation.ps1 files within `C:\Temp`. If the directory does not exist, please create it.
2. Open an administrative PowerShell window on the Windows OS.
3. Validate if PowerShell execution policy type `get-executionpolicy` and hit enter.
4. The response should be either unrestricted or remote signed.
5. If the response returned says restricted, type the following `set-executionpolicy -executionpolicy unrestricted -scope localmachine` then hit enter.
6. Type the following to verify the current settings `get-executionpolicy` and hit enter. The response should be unrestricted.
7. Still within the administrative PowerShell command prompt type `cd C:\Temp`.
8. Type  `.\OCIEnterpriseFederation.ps1` and hit enter.
9. The script will first determine the PowerShell version on the OS.
10. The script will then determine if the metadata.xml file is located within `C:\Temp`. If the file is not present it will signal an error and end the script until this dependency is resolved.
11. Next, the script will determine if both the Azure-AD and Microsoft Graph PowerShell modules are installed. If the modules are missing, they will be added. This may take some time to complete.
12. The script will then initiate a connection with Entra, and the operator is asked to authenticate.
13. The next step, the script will then create a connection with Microsoft Graph and set the proper permission context to create the enterprise application.
14. The script will ask the operator for a name to call the enterprise application. An example would be OCI Federation and hit enter.
15. The script will begin to create the enterprise object within Entra and designate it as a SAML application. With the OCI template from the Entra catalog.
16. The script will then request the OCI URL with the specific identifier of the subscription `https://idcs-< Unique identifier >.identity.oraclecloud.com` please have this information available and once entered hit enter. Please avoid white spaces.
17. The script will add that URL and proper URL endpoints to the enterprise application.
18. Next, the script will create a digital signing certificate for the enterprise application and assign it.
19. The script will request the User Principle Name (UPN) of a valid user within Entra for testing. Format should be `user@<fqdn>` of the registered domain. Hit enter.
20. The script then will proceed to add the user as an authorized user of the enterprise application, create the required Entra Id Groups, and add the specified user to those groups.
21. Once the script is completed, please upload the metadata.xml from `C:\Temp` to the enterprise application and save the settings. Then proceed to hit “test” to validate SSO.
22. Remember to export the Federation XML file from the Azure Enterprise Application that was just provisioned and upload it into the corresponding OCI Federation configuration that was setup prior. 
