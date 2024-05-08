# Source script is beuilt upon https://learn.microsoft.com/en-us/graph/application-saml-sso-configure-api?tabs=powershell%2Cpowershell-script#activate-the-custom-signing-key﻿

# Version 1.1.0

# The following application is provided as is without any guarantees or warranty. 
# Although the author has attempted to find and correct any bugs in the free software programs, 
# the author is not responsible for any damage or losses of any kind caused by the use or misuse of this script. 
# The author is under no obligation to provide support, service, corrections, or upgrades to for this free script. 
# For more information, please send and email to Anthony de Lagarde, Microsoft. 
# Script written 03.21.2024. 

# Version 1.1.1.0

# Read ME!!!

# Intended purpose of this script is to be executed automate the creation of an enterprise application within Entra Id to support Federation between Azure and Oracle Cloud Infrastructure.
# Script must be run under credentials that have been granted the proper rights. The user will require the Application Administrator Role from Entra ID to create an Enterprise Registration, 
# in Entra ID (Azure Active Directory). 

# Please note From Azure AD Group Management requires Entra ID P1 or P2 Licensces. Please refer to the following article: https://learn.microsoft.com/en-us/graph/api/applicationtemplate-list?view=graph-rest-1.0&tabs=http#code-try-1 

# The assumption is the operator has the ability to execute PowerShell scripts from their local workstation or has access to Azure PowerShell Portal via the console. Please try https://shell.azure.com
# Please place the Oracle Metadata.xml file inside the following location C:\Temp\Metadata.xml   IMPORTANT!!!!!! 

# Make sure you only have PowerShell 5.x on your system to run this script or run from the PowerShell ISE

# Get Powershell Version

    Write-Host "Getting the Powershell version"

$PSVersionTable.PSVersion

Write-Host "You need a valid Oracle Cloud Subscription to complete this implementation" -ForegroundColor Yellow


# Testing if the metadata.xml file is within C:\Temp


    $path = "C:\temp\metadata.xml"
        $found = (Test-path $path)

    Write-Host "Testing path c:\temp\metadata.xml file is present on the system" -ForegroundColor Yellow

# Creating function to test the path for the metadata.xml

    if ($found ) {
        Write-Host "The metadata.xml file found!" -foregroundcolor Green
            } else {
                Write-Host "The metadata.xml file is not found. Exiting script until metadata.xml is placed within C:\temp!!" -Foregroundcolor red 
            exit
    }


# Install Azure AD Module if not available on the local system
  
    if (-not (Get-Module -ListAvailable -Name AzureAD)) {
        Write-Host "AzureAD module is not installed. Installing it now..." -ForegroundColor Yellow
            Install-Module -Name AzureAD -Force
    
            Write-Host "AzureAD module has been installed and imported." 
    }
    else {
           Write-Host "AzureAD module is already installed." -ForegroundColor Green
    }

# Importing and Updating the Azure AD Module
 
    Write-Host "Importing AzureAD Module"
  
         Import-Module AzureAD    

    Update-Module -Name AzureAD

  

# Install Microsoft Graph Powershell Module if not available.......

    if (-not (Get-Module -ListAvailable -Name Microsoft.Graph )) {
            Write-Host "Microsoft.Graph module is not installed. Installing it now. Please be patient as this may take a few minutes to complete." -ForegroundColor Yellow
                Install-Module Microsoft.Graph -Scope CurrentUser -Force  
            Write-Host "Microsoft.Graph module has been installed and imported." -ForegroundColor White
            }
        else {
            Write-Host "Microsoft.Graph module is already installed." -ForegroundColor White
    }

#  Import Module Microsoft Graph

    Write-Host "Importing Microsoft Graph Module......" -ForegroundColor Yellow
        Import-Module Microsoft.Graph.Applications

    Write-Host "Sleeping the process for 10 seconds...."
        start-sleep 10


# Getting AzureAD Mudule to list what build  installed

    Write-Host "Listing the PowerShell Module available on your system for Azure AD and microsoft.Graph" 
  
        Write-Host "The following AzureAD Modules are listed below"
            Get-Module AzureAD -ListAvailable

        Write-Host " The following lists the Microsoft.Graph installed."
            Get-Module Microsoft.Graph -ListAvailable

# Connecting to Azure AD

    Write-Host "Connecting to Entra ID"
 
        Connect-Azuread

# Connecting MgGraph with Required Security Scopes
  
        Connect-MgGraph -Scopes 'Application.ReadWrite.All, AppRoleAssignment.ReadWrite.All, Policy.Read.All, Policy.ReadWrite.ApplicationConfiguration, User.ReadWrite.All'

            Start-sleep 15

# OCI ApplicationTemplate Id from MSFT for Enterprise Application Gallery
  
        $applicationTemplateId = "8ac83ca1-af23-41f3-a342-0118ab26754c"

# Requesting the operator to enter the name for the Enterprise Application
  
        $EntName = Read-Host "Please enter a name for your Enterprise Application"

# Creating the Enterprise Application within Entra ID

        $params = @{
                displayName = $EntName
            }

        Invoke-MgInstantiateApplicationTemplate -ApplicationTemplateId $applicationTemplateId -BodyParameter $params

        Start-sleep 10

# Getting the Prinicpal Id for the Enterprise Application
  
        $prinID = Get-MgServicePrincipal -Filter "DisplayName eq '$EntName'" 

# Sharing the Service  Principle Id on the screen with the operator  

        Start-sleep 30                                    
  
        Write-Host " This is the Principal Id of the Enterprise Application" 
            $prinID  

        Start-Sleep 10

# Updating the Service Principal Id on the Enterprise Application


        $params = @{
             preferredSingleSignOnMode = "saml"
        loginUrl                  = "https://cloud.oracle.com"
        }

    Update-MgServicePrincipal -ServicePrincipalId $prinID.Id -BodyParameter $params 



# Geting the Application Name from Graph
  
        $app = get-mgapplication | where DisplayName -EQ $EntName 

# Requesting the operator to enter the OCI Domain eq https://idcs-< Unique identifier >.identity.oraclecloud.com // You need a valid Oracle Cloud Subscription
  

# PowerShell script to validate user input of OCI IDC
    $regex = '^https:\/\/idcs-[a-z0-9]{32}\.identity\.oraclecloud\.com$'
do {
    # Prompt the user for input
    $OCIFQDN = Read-Host "Please enter your Oracle Domain FQDN, example: https://idcs-< Unique identifier >.identity.oraclecloud.com"
    
    # Validate the input
    if ($OCIFQDN -match $regex) {
        Write-Host "Thank you! Your input ($OCIFQDN) is in a valid format." -ForegroundColor Green
        $isValid = $true
    } else {
        Write-Host "Invalid input. Please try again." -ForegroundColor Red 
        $isValid = $false
    } 
} while (-not $isValid)

# Getting the metadata from OCI and setting it as a property within the enterprise application SAML section

        $entityId = ":443/fed"

            $entityUrl = $OCIFQDN + $entityId

 # Getting Reply Url

            $replyurlpath ="/fed/v1/sp/sso"

                $replyurl = $OCIFQDN + $replyurlpath

 # Write-Host "applying the following metadata Url for OCI" -ForegroundColor Yellow

            Write-Host "Applying the saml Url for Federation with Oracle " -ForegroundColor Yellow
  


# Getting the Objectid

   
        $objectId = (Get-AzureADApplication -Filter "DisplayName eq '$EntName'").ObjectId  
  



# Adding the OCI FQDN to the Enterprise Application

$params = @{
    identifierUris = @(
        "$entityUrl"
    )
    web            = @{
        redirectUris = @(
            "$replyurl"
        )
       
    }
}

Update-MgApplication -ApplicationId $app.Id -BodyParameter $params


# Create a token signing certificate for the service principal

        $params = @{
                displayName = "CN=OCIcloudMSFT"
                    endDateTime = [System.DateTime]::Parse("2027-01-22T00:00:00Z")
        }

    Add-MgServicePrincipalTokenSigningCertificate -ServicePrincipalId $prinID.Id -BodyParameter $params

   Write-Host "Remember - Please upload the Metadata.xml file from Oracle Cloud Infrastructure to your Enterprise Application!!!" -ForegroundColor Yellow 

# Assigning a Group to the Enterprise Application

    # Prompt the user to choose whether to create predefined groups
    $createGroups = Read-Host -Prompt 'Do you want to create predefined groups? (y/n)'

    if ($createGroups -eq 'y') {
        # Define the list of group names
        $groupNames = @("odbaa-exa-infra-administrator", "odbaa-vm-cluster-administrator", "odbaa-db-family-administrators", "odbaa-db-family-readers", "odbaa-exa-cdb-administrators", "odbaa-exa-pdb-administrators", "odbaa-costmgmt-administrators")

        Write-Host "Adding the specified Entra Id Groups to the Enterprise Application" -ForegroundColor Green

        # Loop through each group name
        foreach ($groupName in $groupNames) {
            # Check if the group already exists
            $group = Get-AzureADGroup -SearchString $groupName

            # If the group doesn't exist, create it
            if ($null -eq $group) {
                $group = New-AzureADGroup -DisplayName $groupName -MailEnabled $false -SecurityEnabled $true -MailNickName "NotSet"
                Write-Host "Created the group $groupName" -ForegroundColor Green
            }
        }
    } else if ($createGroups -eq 'n') {
        Write-Host "No groups will be created." -ForegroundColor Yellow
    } else {
        Write-Host "Invalid input. Please try again." -ForegroundColor Red
        exit
    }

    # Prompt the user to choose whether to add groups to the Enterprise App
    $addGroups = Read-Host -Prompt 'Do you want to add groups to the Enterprise App? (y/n)'

    if ($addGroups -eq 'y') {
        # Loop through each group name
        foreach ($groupName in $groupNames) {
            # Get the group
            $group = Get-AzureADGroup -SearchString $groupName

            # Assign the group to the Enterprise Application
            New-AzureADGroupAppRoleAssignment -ObjectId $group.ObjectId -PrincipalId $group.ObjectId -ResourceId $spo.ObjectId -Id $app.AppRoles[1].Id
            Write-Host "Added the group $groupName to the Enterprise Application" -ForegroundColor Green
        }
    } else if ($addGroups -eq 'n') {
        Write-Host "No groups will be added to the Enterprise Application." -ForegroundColor Yellow
    } else {
        Write-Host "Invalid input. Please try again." -ForegroundColor Red
        exit
    }

   Write-Host "Remember - Please upload the C:\Temp\Metadata.xml file from Oracle Cloud Infrastructure to your Enterprise Application!!!" -ForegroundColor Yellow 

   Write-Host "Remember - Please download the Azure Federation XML file from your Azure Enterprise OCI Application and provide it for the OCI Federation setup to complete the setup!!!" -ForegroundColor Yellow 
 
    Write-Host "Provisioning has completed. Please test your Application Federation with Oracle Cloud Infrastructure!!!" -ForegroundColor Green
    Write-Host "Users are not synced automatically between Azure and OCI. You have to assign users to each group manually." -ForegroundColor Yellow