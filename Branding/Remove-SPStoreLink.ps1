#Add references to SharePoint client assemblies and authenticate to Office 365 site
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Username = Read-Host -Prompt "Please enter your username"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Site = "https://tenant.sharepoint.com/sites/site"
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)
$Context.Credentials = $Creds

#Load User Custom Actions
$CustomActions = $Context.Web.UserCustomActions
$Context.Load($CustomActions)
$Context.ExecuteQuery()

#Add an action to remove the link to the SharePoint Store when adding an App
$AddAction = $CustomActions.Add()
$AddAction.Location = "ScriptLink"
$AddAction.Name = "RemoveSPStore"
$AddAction.ScriptBlock = "window.onload = function(e){var links = document.getElementsByClassName('ms-storefront-selectanchor ms-core-listMenu-item');links[5].style.display = 'none'};"
$AddAction.Update()
$Context.ExecuteQuery()

#Remove the user custom action
$AddAction.DeleteObject()
$Context.ExecuteQuery()
