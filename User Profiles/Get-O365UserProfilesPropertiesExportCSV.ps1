#Specify tenant admin
$User = ""

#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.UserProfiles.dll"

$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Password)

#Configure MySite Host URL
$SiteURL = ""

#Bind to Site Collection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Context.Credentials = $Creds

#Identify users in the Site Collection
$Users = $Context.Web.SiteUsers
$Context.Load($Users)
$Context.ExecuteQuery()

#Create People Manager object to retrieve profile data
$Output = "C:\Output.csv"
$Headings = "Name","Email","OneDrive URL","Phone","Job Title","Department"
$Headings -join "," | Out-File -Encoding default -FilePath $Output

$PeopleManager = New-Object Microsoft.SharePoint.Client.UserProfiles.PeopleManager($Context)
Foreach ($User in $Users)
    {
    $UserProfile = $PeopleManager.GetPropertiesFor($User.LoginName)
    $Context.Load($UserProfile)
    $Context.ExecuteQuery()
    If ($UserProfile.Email -ne $null)
        {
        $UPP = $UserProfile.UserProfileProperties
        $Properties = $UserProfile.DisplayName,$UserProfile.Email,$UserProfile.PersonalUrl, $UPP.WorkPhone,$UPP.'SPS-JobTitle',$UPP.Department
        $Properties -join "," | Out-File -Encoding default -Append -FilePath $Output
        }  
    }

