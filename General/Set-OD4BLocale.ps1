#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.UserProfiles.dll"

#Specify tenant admin
$User = "admin@tenant.onmicrosoft.com"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Password)

#Configure MySite Host URL
$SiteURL = "https://tenant-my.sharepoint.com/"

#Bind to MySite Host Site Collection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Context.Credentials = $Creds

#Identify users in the Site Collection
$Users = $Context.Web.SiteUsers
$Context.Load($Users)
$Context.ExecuteQuery()

#Create People Manager object to retrieve profile data
$PeopleManager = New-Object Microsoft.SharePoint.Client.UserProfiles.PeopleManager($Context)
Foreach ($User in $Users)
    {
    $UserProfile = $PeopleManager.GetPropertiesFor($User.LoginName)
    $Context.Load($UserProfile)
    $Context.ExecuteQuery()
    If ($UserProfile.Email -ne $null)
        {
        Write-Host "User:" $User.LoginName -ForegroundColor Green
        #Bind to OD4B Site and change locale
        $OD4BSiteURL = $UserProfile.PersonalUrl
        $Context2 = New-Object Microsoft.SharePoint.Client.ClientContext($OD4BSiteURL)
        $Context2.Credentials = $Creds
        $Context2.ExecuteQuery()
        $Context2.Web.RegionalSettings.LocaleId = "2057"
        $Context2.Web.Update()
        $Context2.ExecuteQuery()
        }  
    }