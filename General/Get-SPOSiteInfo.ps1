#Specify tenant admin and URL
$User = ""
$TenantURL = ""

#O365 Cmdlets to connet to a tenant
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking -ErrorAction SilentlyContinue
Connect-SPOService -Url $TenantURL -credential $User

#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\15\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Password)

#Loop through all Site Collections within the tenant
$Sites = Get-SPOSite -Detailed | Where {$_.URL -notlike "*-public*"}

Foreach ($Site in $Sites)
{
    #$SiteURL = $Site.URL;
    $Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site.URL);
    $Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Password);
    $Context.Credentials = $Creds;

    Write-Host "Checking" $Site.URL -ForegroundColor Green;
    Write-Host "     Storage Quota:"$Site.StorageQuota"" -ForegroundColor White
    [INT]$StorageUtil = $Site.StorageUsageCurrent/$Site.StorageQuota * 100
    Write-Host "     Storage Used:"$StorageUtil%"" -ForegroundColor White
    Write-Host "     Lock Status:"$Site.LockState"" -ForegroundColor White
    Write-Host "     Template:"$Site.Template"" -ForegroundColor White
    $Owner = $Context.Site.Owner
    $Context.Load($Owner)
    $Context.ExecuteQuery()
    If ($Owner.Email -ne "")
        {
        Write-Host "     Owner:"$Owner.Email -ForegroundColor White
        }

    $Webs = $Context.Web.Webs
    $Context.Load($Webs)
    $Context.ExecuteQuery()
    If ($Webs.Count -gt 0)
        {
        Write-Host "     "$Webs.Count" Sub-Web(s) Found:" -ForegroundColor White;
        Write-Host "     ------------------------------" -ForegroundColor Yellow
        }

#Loop through each Web within the Site Collection
    Foreach ($Web in $Webs) 
        {
        $Lists = $Context.Web.Lists
        $Context.Load($Lists)
        $Context.ExecuteQuery()
        $WebConfig = ""
        If ($Web.Configuration -ne "-1") {$WebConfig = $Web.Configuration}
        Write-Host "     Web URL": $Web.ServerRelativeURL -ForegroundColor Yellow;
        Write-Host "     Created": $Web.Created -ForegroundColor Yellow;
        Write-Host "     Template": $Web.WebTemplate"#"$WebConfig -ForegroundColor Yellow;
        Write-Host "     "$Lists.Count" List(s) Found" -ForegroundColor Yellow;
        Write-Host "     ------------------------------" -ForegroundColor Yellow;
        }

}