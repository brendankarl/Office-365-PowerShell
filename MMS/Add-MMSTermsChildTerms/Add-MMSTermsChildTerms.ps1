$Terms = Import-CSV D:\Terms.csv
$Site = "https://tenant.sharepoint.com"
$GroupName = "Locations"
$TermSetName = "UK"

Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
$Username = Read-Host -Prompt "Enter your username"
$Password = Read-Host -Prompt "Enter your password" -AsSecureString
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)

#Bind to MMS
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site)
$Context.Credentials = $Creds
$MMS = [Microsoft.SharePoint.Client.Taxonomy.TaxonomySession]::GetTaxonomySession($Context)
$Context.Load($MMS)
$Context.ExecuteQuery()

#Retrieve Term Stores
$TermStores = $MMS.TermStores
$Context.Load($TermStores)
$Context.ExecuteQuery()

#Bind to Term Store
$TermStore = $TermStores[0]
$Context.Load($TermStore)
$Context.ExecuteQuery()

#Bind to Group
$Group = $TermStore.Groups.GetByName($GroupName)
$Context.Load($Group)
$Context.ExecuteQuery()

#Bind to Term Set
$TermSet = $Group.TermSets.GetByName($TermSetName)
$Context.Load($TermSet)
$Context.ExecuteQuery()


$L1Terms = $Terms | Select L1T -Unique
Foreach ($Term in $L1Terms)
{
Write-Host "Creating L1 Term" $Term.L1T -ForegroundColor Green
$TermAdd = $TermSet.CreateTerm(($Term.L1T),1033,[System.Guid]::NewGuid().toString())
$Context.Load($TermAdd)
$Context.ExecuteQuery()
$L2Terms = $Terms | Where {$_.L1T -eq $Term.L1T}
Foreach ($L2Term in $L2Terms)
    {
    Write-Host "-L2 Term" $L2Term.L2T -ForegroundColor Yellow
    $L2TermAdd = $TermAdd.CreateTerm(($L2Term.L2T),1033,[System.Guid]::NewGuid().toString())
    $Context.Load($L2TermAdd)
    $Context.ExecuteQuery()
    }
}