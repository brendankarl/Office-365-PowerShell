#Add Assemblies and Authenticate
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking -ErrorAction SilentlyContinue
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Username = Read-Host -Prompt "Enter your username"
$Password = Read-Host -Prompt "Enter your password" -AsSecureString
$TenantName = Read-Host -Prompt "Enter tenant name"
$Cred = New-Object System.Management.Automation.PSCredential $Username, $Password
Connect-SPOService -Url https://$TenantName-admin.sharepoint.com -Credential $Cred

#Loop through each Site Collection and Output all First Level Webs
Foreach ($SC in (Get-SPOSite -Detailed))
{
$Site = $SC.URL
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)
$Context.Credentials = $Creds
$Webs = $Context.Site.RootWeb.Webs
$Context.Load($Webs)
$Context.ExecuteQuery()
Write-Host $Site -ForegroundColor Green
Foreach ($Web in $Webs)
    {
    Write-Host "-"$Web.URL -ForegroundColor Yellow
    }
}