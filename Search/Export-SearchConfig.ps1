#Specify tenant admin, site URL and scope to export from
$User = ""
$SiteURL = ""
$Scope = "SPSite"
$Schema = "C:\SearchSchema.XML"

#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Search.dll"

$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Password)

#Export search configuration
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Context.Credentials = $Creds
$Owner = New-Object Microsoft.SharePoint.Client.Search.Administration.SearchObjectOwner($Context,$Scope)
$Search = New-Object Microsoft.SharePoint.Client.Search.Portability.SearchConfigurationPortability($Context)
$SearchConfig = $Search.ExportSearchConfiguration($Owner)
$Context.ExecuteQuery()
$SearchConfig.Value > $Schema