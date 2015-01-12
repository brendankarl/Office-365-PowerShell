#Add references to SharePoint client assemblies and authenticate to Office 365 site
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Username = ""
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString

Function ActivateSiteFeature ($SiteURL,$SiteFeatureGUID)
{
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)
$Context.Credentials = $Creds

#Bind to Site Collection
$SiteFeatures = $Context.Site.Features
$Context.Load($SiteFeatures)
$Context.ExecuteQuery()

#Activate Site Collection Feature
$SiteFeatures.Add($SiteFeatureGUID,$force,[Microsoft.SharePoint.Client.FeatureDefinitionScope]::None)
$Context.Load($SiteFeatures)
$Context.ExecuteQuery()
}

Function ActivateWebFeature ($WebURL, $WebFeatureGUID)
{
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($WebURL)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)
$Context.Credentials = $Creds

#Bind to Web
$Web = $Context.Web
$Context.Load($Web)
$Context.ExecuteQuery()

#Activate Web Feature
$Web.Features.Add($WebFeatureGUID,$force,[Microsoft.SharePoint.Client.FeatureDefinitionScope]::None)
$Context.Load($Web)
$Context.ExecuteQuery()
}

Function DeactivateSiteFeature ($SiteURL,$SiteFeatureGUID)
{
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)
$Context.Credentials = $Creds

#Bind to Site Collection
$SiteFeatures = $Context.Site.Features
$Context.Load($SiteFeatures)
$Context.ExecuteQuery()

#Activate Site Collection Feature
$SiteFeatures.Remove($SiteFeatureGUID,$force)
$Context.Load($SiteFeatures)
$Context.ExecuteQuery()
}

Function DeactivateWebFeature ($WebURL, $WebFeatureGUID)
{
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($WebURL)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)
$Context.Credentials = $Creds

#Bind to Web
$Web = $Context.Web
$Context.Load($Web)
$Context.ExecuteQuery()

#Activate Web Feature
$Web.Features.Remove($WebFeatureGUID,$force)
$Context.Load($Web)
$Context.ExecuteQuery()
}