#Specify Tenant Admin URL
$TenantAdminURL = "https://tenant-admin.sharepoint.com"
$SiteURL = "https://tenant.sharepoint.com/sites/site"

#O365 Cmdlets to connect to a tenant
Import-Module Microsoft.Online.SharePoint.PowerShell -DisableNameChecking -ErrorAction SilentlyContinue
Connect-SPOService -Url $TenantAdminURL

#Return all users for a specific Site Collection
Get-SPOUser -Site $SiteURL | Select DisplayName, LoginName, IsSiteAdmin, Groups | ft -AutoSize                                                                                           