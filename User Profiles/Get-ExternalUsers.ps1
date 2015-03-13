#Specify tenant admin and URL
$User = ""
$TenantURL = ""

#O365 Cmdlets to connet to a tenant
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking -ErrorAction SilentlyContinue
Connect-SPOService -Url $TenantURL -credential $User

$Output = "D:\Output.CSV"
"Site URL"+","+"External User" | Out-File -Encoding Default -FilePath $Output

#Check Sites
Write-Host "Checking Sharepoint Online sites for External Users" -ForegroundColor Green
$Sites = Get-SPOSite | Where {$_.SharingCapability -ne "Disabled"}
Foreach ($Site in $Sites)
{
Write-Host Checking $Site.URL -ForegroundColor Yellow
ForEach ($User in (Get-SPOExternalUser -SiteUrl $Site.URL))
{
Write-Host "-" $User.Email "Found!" -ForegroundColor White
$Site.URL + "," + $User.Email | Out-File -Encoding Default -Append -FilePath $Output
}
}