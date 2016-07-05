#Add references to SharePoint client assemblies and authenticate to Office 365 site
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Username = Read-Host -Prompt "Please enter your username"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Site = "https://tenant.sharepoint.com"
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)
$Context.Credentials = $Creds

$List = $Context.Web.Lists.GetByTitle("CustomList")
$Context.Load($List)
$Context.ExecuteQuery()

$i = 0
While ($i -lt "500")
{
$ListItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
$Item = $List.AddItem($ListItemInfo)
$Item["Title"] = "Title$i"
$Item["Product"] = "Product$i"
$Item.Update()
$Context.ExecuteQuery() 
$i++
}