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

#Output to CSV file
$Output = "$env:USERPROFILE" + "\Desktop\OD4BUsage.csv"
$Headings = "URL" + "," + "Size (MB)" + "," + "Total Number of Items"+ "," + "Oldest File" + "," + "Newest File" | Out-File -Encoding default -FilePath $Output

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
Write-Host "-Collecting Data from:" $URL -ForegroundColor Yellow
Try {
#Storage Used
$OD4BURL = $URL.TrimEnd("/")
$StorageUsed = (Get-SPOSite "https://$Tenant-my.sharepoint.com$OD4BURL").StorageUsageCurrent
#Bind to OD4B
$Context = New-Object Microsoft.SharePoint.Client.ClientContext("https://$Tenant-my.sharepoint.com$OD4BURL")
$Context.Credentials = $Creds
$List = $Context.Web.Lists.GetByTitle("Documents")
$Context.Load($List)
$Context.ExecuteQuery()
#Oldest Item
$OldestFileCreated = $null
$OldestCAML = New-Object Microsoft.SharePoint.Client.CamlQuery
$OldestCAML.ViewXml = "
<View Scope='RecursiveAll'>  
            <Query> 
               <Where><Eq><FieldRef Name='FSObjType' /><Value Type='Integer'>0</Value></Eq></Where><OrderBy><FieldRef Name='Created' Ascending='TRUE' /></OrderBy> 
            </Query> 
             <ViewFields><FieldRef Name='Created' /></ViewFields> 
            <RowLimit>1</RowLimit> 
      </View>"
$OldestFile = $List.GetItems($OldestCAML)
$Context.Load($OldestFile)
$Context.ExecuteQuery()
Try {
$OldestFileCreated = ($OldestFile[0])["Created"]
}
Catch {}
#Newest Item
$NewestFileCreated = $null
$NewestCAML = New-Object Microsoft.SharePoint.Client.CamlQuery
$NewestCAML.ViewXml = "
<View Scope='RecursiveAll'>  
            <Query> 
               <Where><Eq><FieldRef Name='FSObjType' /><Value Type='Integer'>0</Value></Eq></Where><OrderBy><FieldRef Name='Modified' Ascending='FALSE' /></OrderBy> 
            </Query> 
             <ViewFields><FieldRef Name='Modified' /></ViewFields> 
            <RowLimit>1</RowLimit> 
      </View>"
$NewestFile = $List.GetItems($NewestCAML)
$Context.Load($NewestFile)
$Context.ExecuteQuery()
Try {
$NewestFileCreated = ($NewestFile[0])["Modified"]
}
Catch {}

#Output to CSV file
$URL + "," + $StorageUsed + "," + $List.ItemCount + "," + $OldestFileCreated + "," + $NewestFileCreated | Out-File -Encoding Default -Append -FilePath $Output
}


Catch {
Write-Host "-Error Accessing Site" -ForegroundColor Red
}
}
$UserProfileResult = $UserProfileService.GetUserProfileByIndex($UserProfileResult.NextValue)
$i++
}
