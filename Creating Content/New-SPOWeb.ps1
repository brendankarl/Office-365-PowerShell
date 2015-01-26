#Add references to SharePoint client assemblies and authenticate to Office 365 site
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Publishing.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Username = Read-Host -Prompt "Please enter your username"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Site = ""
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)
$Context.Credentials = $Creds

#Create SubSite
$WCI = New-Object Microsoft.SharePoint.Client.WebCreationInformation
$WCI.WebTemplate = "STS#0"
$WCI.Description = "SubSite"
$WCI.Title = "SubSite"
$WCI.Url = "SubSite"
$WCI.Language = "1033"
$SubWeb = $Context.Web.Webs.Add($WCI)
$Context.ExecuteQuery()

#Create SubSubSite
$WCI = New-Object Microsoft.SharePoint.Client.WebCreationInformation
$WCI.WebTemplate = "STS#0"
$WCI.Description = "SubSubSite"
$WCI.Title = "SubSubSite"
$WCI.Url = "SubSite/SubSubSite"
$WCI.Language = "1033"
$SubWeb = $Context.Web.Webs.Add($WCI)
$Context.ExecuteQuery()