#Specify tenant admin and URL
$User = "admin@tenant.onmicrosoft.com"
$TenantURL = "https://tenant-admin.sharepoint.com"
$Site = "https://tenant.sharepoint.com"
$GroupName = "Products"
$TermSetName = "Entry Level"
$SourceTermSetName = "Widget x"
$SourceTermName = "Widget x1000"
$DestTermSetName = "Widget y"
$DestTermName = "Widget y1000"

#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Taxonomy.dll"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString

#Bind to MMS
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Password)
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

#Retrieve Groups
$Groups = $TermStore.Groups
$Context.Load($Groups)
$Context.ExecuteQuery()

Foreach ($Group in $Groups)
{
Write-Host $Group.Name
}

$Group = $Groups | Where {$_.Name -eq $GroupName}
$Context.Load($Group)
$Context.ExecuteQuery()

$TermSet = $Group.TermSets
$Context.Load($TermSet)
$Context.ExecuteQuery()

$TermSet = $Group.TermSets | Where {$_.Name -eq $TermSetName}
$Context.Load($TermSet)
$Context.ExecuteQuery()

$Terms = $TermSet.Terms
$Context.Load($Terms)
$Context.ExecuteQuery()

#Bind to Term Sets
$Source = $Terms | Where {$_.Name -eq $SourceTermSetName}
$Context.Load($Source)
$Context.ExecuteQuery()

$Destination = $Terms | Where {$_.Name -eq $DestTermSetName}
$Context.Load($Destination)
$Context.ExecuteQuery()

#Move
$ChildTerms = $Source.Terms
$Context.Load($ChildTerms)
$Context.ExecuteQuery()

$SourceTerm = $Source.Terms | Where {$_.Name -eq $SourceTermName}
$Context.Load($SourceTerm)
$Context.ExecuteQuery()

$Move = $SourceTerm.Move($Destination)
$Context.ExecuteQuery()

#Merge
$Destination = $Terms | Where {$_.Name -eq $DestTermSetName}
$Context.Load($Destination)
$Context.ExecuteQuery()

$ChildTerms = $Destination.Terms
$Context.Load($ChildTerms)
$Context.ExecuteQuery()

$DestTerm = $Destination.Terms | Where {$_.Name -eq $DestTermName}
$Context.Load($DestTerm)
$Context.ExecuteQuery()

$SourceTerm = $Destination.Terms | Where {$_.Name -eq $SourceTermName}
$Context.Load($SourceTerm)
$Context.ExecuteQuery()

$Merge = $SourceTerm.Merge($DestTerm)
$Context.Load($Merge)
$Context.ExecuteQuery() 