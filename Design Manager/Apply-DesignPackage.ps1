#Add references to SharePoint client assemblies and authenticate to Office 365 site
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Publishing.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Username = ""
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Site = ""
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)
$Context.Credentials = $Creds
$Folder = "C:\Uploads"
$DocLibName = "Docs"

#Bind to Site Collection
$SC = $Context.Site
$Context.Load($SC)
$Context.ExecuteQuery()

#Retrieve List
$List = $SC.RootWeb.Lists.GetByTitle($DocLibName)
$Context.Load($List)
$Context.ExecuteQuery()

#Upload file
$File = dir $Folder | Where {$_.Extension -eq ".wsp"}
$FileStream = [System.IO.File]::ReadAllBytes($File[0].FullName)
$FileCreationInfo = New-Object Microsoft.SharePoint.Client.FileCreationInformation
$FileCreationInfo.Overwrite = $true
$FileCreationInfo.Content = $FileStream
$FileCreationInfo.URL = $File[0]
$Upload = $List.RootFolder.Files.Add($FileCreationInfo)
$Context.Load($Upload)
$Context.ExecuteQuery()

#Create a Design Package Info object
$DPI = New-Object Microsoft.SharePoint.Client.Publishing.DesignPackageInfo
$DPI.PackageName = "Branding"
$DPI.PackageGUID = [GUID]::Empty
$DPI.MajorVersion = "1"
$DPI.MinorVersion = "0"

#Create a Design Package using the Design Package Info ($DPI) and Install to the Site Collection
$DPURL = $SC.ServerRelativeUrl + "/" + $DocLibName + "/" + $File[0].Name
$DP = [Microsoft.SharePoint.Client.Publishing.DesignPackage]::Install($Context,$SC,$DPI,$DPURL)
$Context.ExecuteQuery()

#Use CAML to locate temporary WSP
$ItemName = $File[0].Name
$CAML = New-Object Microsoft.SharePoint.Client.CamlQuery
$CAML.ViewXml = "<View><Query><Where><Eq><FieldRef Name='FileLeafRef'/><Value Type='File'>$ItemName</Value></Eq></Where></Query></View>"
$Item = $List.GetItems($CAML)
$Context.Load($Item)
$Context.ExecuteQuery()

#Delete temporary WSP
$Item.Recycle()
$Context.Load($Item)
$Context.ExecuteQuery()