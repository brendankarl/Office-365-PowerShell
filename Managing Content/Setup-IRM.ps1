#Add references to SharePoint client assemblies and authenticate to Office 365 site
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Username = Read-Host -Prompt "Please enter your username"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Site = "https://site.sharepoint.com"
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)
$Context.Credentials = $Creds

#List lists
$Lists = $Context.Web.Lists
$Context.Load($Lists)
$Context.ExecuteQuery()

#Bind to list "documents"
$List = $Lists.GetByTitle("Documents")
$Context.Load($List)
$Context.ExecuteQuery()

#Enable IRM
$List.IrmEnabled = $true 

#Give the Policy a Name and Description
$List.InformationRightsManagementSettings.PolicyDescription = "Test" #Policy Description
$List.InformationRightsManagementSettings.PolicyTitle = "Test "#Policy Name

#Configure the Policy Settings
$List.InformationRightsManagementSettings.AllowPrint = $true
$List.InformationRightsManagementSettings.AllowScript = $true
$List.InformationRightsManagementSettings.AllowWriteCopy = $true
$List.InformationRightsManagementSettings.DisableDocumentBrowserView = $true
$List.InformationRightsManagementSettings.DocumentAccessExpireDays = 10
$List.InformationRightsManagementSettings.DocumentLibraryProtectionExpireDate = "01/01/2016"
$List.InformationRightsManagementSettings.EnableDocumentAccessExpire = $true
$List.InformationRightsManagementSettings.EnableDocumentBrowserPublishingView = $true
$List.InformationRightsManagementSettings.EnableGroupProtection = $false
$List.InformationRightsManagementSettings.EnableLicenseCacheExpire = $true
$List.InformationRightsManagementSettings.LicenseCacheExpireDays = 5
$List.InformationRightsManagementSettings.GroupName = $null
$List.Update()
$Context.ExecuteQuery()

#Output Current Settings
$List.InformationRightsManagementSettings