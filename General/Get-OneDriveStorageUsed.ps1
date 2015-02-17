#This script outputs the total storage used by the OneDrive site specified in the $SiteURL variable
$SiteURL = "https://tenant-my.sharepoint.com/personal/first_last_onmicrosoft_com"
$User = "admin@tenant.onmicrosoft.com"
$Password = Read-Host -Prompt "Enter password" -AsSecureString 

$Assemblies = ( 
    "Microsoft.SharePoint.Client, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c", 
    "Microsoft.SharePoint.Client.Runtime, Version=16.0.0.0, Culture=neutral, PublicKeyToken=71e9bce111e9429c",
    "System.Core, Version=3.5.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089"
)
$CSharp = @"
using Microsoft.SharePoint.Client;
using System.Collections.Generic;
using System.Linq;
public static class QueryHelperLinq
{
    public static void LoadSiteUsage(ClientContext ctx, Microsoft.SharePoint.Client.Site site)
    {
        ctx.Load(site, s => s.Usage);
    }
}
"@

Add-Type -ReferencedAssemblies $Assemblies -TypeDefinition $CSharp -Language CSharp;
Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll" 
Add-Type -Path "C:\Program Files\Common Files\microsoft shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL) 
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Password) 
$Context.Credentials = $Creds
$Site = $Context.Site
[QueryHelperLinq]::LoadSiteUsage($Context, $Site)
$Context.ExecuteQuery()
Write-Host $SiteURL "is using" ([Decimal]::Round($Site.Usage.Storage /1MB)) "MB Storage" -ForegroundColor Green