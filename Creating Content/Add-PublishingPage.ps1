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

$Rootweb = $Context.Site.RootWeb
$MPList = $Rootweb.Lists.GetByTitle('Master Page Gallery')
$CAML = New-Object Microsoft.SharePoint.Client.CamlQuery
$CAML.ViewXml = '<View><Query><Where><Eq><FieldRef Name="FileLeafRef" /> `
                          <Value Type="Text">ArticleLeft.aspx</Value></Eq></Where></Query></View>'
$Items = $MPList.GetItems($CAML)
$Context.Load($Items)
$Context.ExecuteQuery()

$PageLayout = $Items[0]
$Context.Load($PageLayout)

$PubWeb = [Microsoft.SharePoint.Client.Publishing.PublishingWeb]::GetPublishingWeb($Context,$RootWeb)
$Context.Load($PubWeb)

$PagesList = $Context.Web.Lists.GetByTitle('Pages')
$Title = "Title"
$Content = "Content"

$PubPageInfo = New-Object Microsoft.SharePoint.Client.Publishing.PublishingPageInformation
$PubPageInfo.Name = $Title + ".aspx"
$PubPageInfo.PageLayoutListItem = $PageLayout
$Page = $PubWeb.AddPublishingPage($PubPageInfo)
$Page.ListItem.File.CheckIn("",[Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
$Page.ListItem.File.Publish("")
$Context.Load($Page)
$Context.ExecuteQuery()

$Item = $Page.ListItem
$Context.Load($Item)
$Context.ExecuteQuery()

$File = $Item.File
$File.CheckOut()
$Context.Load($File)
$Context.ExecuteQuery()
$Item.Set_Item("Title", $Title)
$Item.Set_Item("PublishingPageContent", $Content)
$Item.Update()
$Item.File.CheckIn("", [Microsoft.SharePoint.Client.CheckinType]::MajorCheckIn)
$Item.File.Publish("")
$Context.Load($Item)
$Context.ExecuteQuery()