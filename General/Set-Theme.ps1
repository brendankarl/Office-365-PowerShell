#Specify tenant admin and site URL
$User = ""
$SiteURL = ""

#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Password)

#Bind to site collection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Context.Credentials = $Creds

#Bind to Web
$Web = $Context.Web
$Context.Load($Web)
$Context.ExecuteQuery()

#Change theme
$Color = "/sites/sitename/lib/palette.spcolor"
$Font = "/sites/sitename/lib/font.spfont"
$Image = "/sites/sitename/lib/image.jpg"
$Web.ApplyTheme($Color,$Font,$Image,$true)
$Context.ExecuteQuery()