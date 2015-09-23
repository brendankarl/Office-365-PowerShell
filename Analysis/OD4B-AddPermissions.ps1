#==================================================================
# DISCLAIMER:
#
# This sample is provided as is and is not meant for use on a
# production environment. It is provided only for illustrative
# purposes. The end user must test and modify the sample to suit
# their target environment.
#
# Microsoft can make no representation concerning the content of
# this sample. Microsoft is providing this information only as a
# convenience to you. This is to inform you that Microsoft has not
# tested the sample and therefore cannot make any representations
# regarding the quality, safety, or suitability of any code or
# information found here.
#
#===================================================================


#WARNING!!!! This user will be granted Site Collection Admin permissions to ALL OD4B Sites
$UserToAdd = "user@tenant.onmicrosoft.com"
#WARNING!!!! This user will be granted Site Collection Admin permissions to ALL OD4B Sites

#Add SharePoint Onlice CSOM Assemblies and PowerShell Module
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking -ErrorAction SilentlyContinue

#Authenticate
$Username = Read-Host -Prompt "Please enter your username"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Tenant = Read-Host -Prompt "Please enter tenant name e.g. ContosoO365"
$AdminURI = "https://$Tenant-admin.sharepoint.com"
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)
$Creds2 = New-Object System.Management.Automation.PSCredential $Username, $Password
Connect-SPOService -Url $AdminURI -Credential $Creds2

#Add the path of the User Profile Service to the SPO admin URL, then create a new webservice proxy to access it
$proxyaddr = "$AdminURI/_vti_bin/UserProfileService.asmx?wsdl"
$UserProfileService= New-WebServiceProxy -Uri $proxyaddr -UseDefaultCredential False
$UserProfileService.Credentials = $Creds

#Take care of auth cookies
$strAuthCookie = $Creds.GetAuthenticationCookie($AdminURI)
$uri = New-Object System.Uri($AdminURI)
$container = New-Object System.Net.CookieContainer
$container.SetCookies($uri, $strAuthCookie)
$UserProfileService.CookieContainer = $container

#Grab the first User profile, at index -1
$UserProfileResult = $UserProfileService.GetUserProfileByIndex(-1)
$NumProfiles = $UserProfileService.GetUserProfileCount()
$i = 1

# As long as the next User profile is NOT the one we started with (at -1)...
While ($UserProfileResult.NextValue -ne -1) 
{
Write-Host "Examining Profile $i of $NumProfiles" -ForegroundColor Green

# Look for the Personal Space object in the User Profile and pull it out
# (PersonalSpace is the name of the path to a user's OD4B)
$Prop = $UserProfileResult.UserProfile | Where-Object { $_.Name -eq "PersonalSpace" } 
$Url= $Prop.Values[0].Value

if ($Url) {
Write-Host "-Granting Permissions to:" $URL -ForegroundColor Yellow
$OD4BURL = $URL.TrimEnd("/")
$a = Set-SPOUser -Site "https://$Tenant-my.sharepoint.com$OD4BURL" -LoginName $UserToAdd -IsSiteCollectionAdmin $true
}
$UserProfileResult = $UserProfileService.GetUserProfileByIndex($UserProfileResult.NextValue)
$i++
}
