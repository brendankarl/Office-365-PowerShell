#Tenant Admin URL
$Site = "https://tenant-admin.sharepoint.com"

#Add references to SharePoint client assemblies and authenticate to Office 365 site
Add-Type -Path "D:\CSOM\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "D:\CSOM\Microsoft.SharePoint.Client.Publishing.dll"
Add-Type -Path "D:\CSOM\Microsoft.Online.SharePoint.Client.Tenant.dll"
$Username = Read-Host "Please enter your username"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)
$Context.Credentials = $Creds

#Create tenant object and output current settings
$Tenant = New-Object Microsoft.Online.SharePoint.TenantAdministration.Tenant($Context)
$Context.Load($Tenant)
$Context.ExecuteQuery()
$Tenant