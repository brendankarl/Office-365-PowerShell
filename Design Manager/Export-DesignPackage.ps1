$Site = ""
$DestinationDir = "C:\Uploads\"

#Add references to SharePoint client assemblies and authenticate to Office 365 site
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Publishing.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Username = ""
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)
$Context.Credentials = $Creds

$SC = $Context.Site
$Context.Load($SC)
$Context.ExecuteQuery()

$RootWeb = $SC.RootWeb
$Context.Load($RootWeb)
$Context.ExecuteQuery()

$DP = [Microsoft.SharePoint.Client.Publishing.DesignPackage]::ExportEnterprise($Context,$SC,$True)
$Context.ExecuteQuery()

#Download Design Package
$Package =  $SC.ServerRelativeUrl + "/_catalogs/Solutions/" + $RootWeb.Title + "-1.0.wsp"
$Destination =  $DestinationDir + $RootWeb.Title + "-1.0.wsp"
$FileInfo = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($Context,$Package)
$WriteStream = [System.IO.File]::Open($Destination,[System.IO.FileMode]::Create);
$FileInfo.Stream.CopyTo($WriteStream)
$WriteStream.Close();