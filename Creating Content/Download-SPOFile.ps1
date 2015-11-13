#Specify variables
$User = "admin@tenant.onmicrosoft.com"
$SiteURL = "https://tenant.sharepoint.com"
$URLPath = "/Shared Documents/Book1.xlsx"
$Target = $URLPath.Split("/")[-1]

#Add references to SharePoint client assemblies
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString

Try {
#Bind to site collection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Password)
$Context.Credentials = $Creds
}
Catch {
Write-Host "Unable to open Site Collection" $SiteURL -ForegroundColor Red
}

$TimeTaken = Measure-Command {
Try {
#Download File
Write-Host "Downloading" $Target "..." -ForegroundColor Yellow
$FileInfo = [Microsoft.SharePoint.Client.File]::OpenBinaryDirect($Context,$URLPath)
[System.IO.FileStream] $WriteStream = [System.IO.File]::Open($Target,[System.IO.FileMode]::Create);
$FileInfo.Stream.CopyTo($WriteStream);
$WriteStream.Close()
}
Catch {
Write-Host "Unable to download file" $SiteURL -ForegroundColor Red
}
}

$TotalSeconds = [INT]$TimeTaken.TotalSeconds
Write-Host "-Download took" $TotalSeconds "Seconds" -ForegroundColor Green