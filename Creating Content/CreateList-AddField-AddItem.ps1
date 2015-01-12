#Specify tenant admin and site URL
$User = ""
$SiteURL = ""
$ListTitle = ""

#Add references to SharePoint client assemblies and authenticate to Office 365 site - required for CSOM
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Password)

#Bind to site collection
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($SiteURL)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($User,$Password)
$Context.Credentials = $Creds

#Retrieve lists
$Lists = $Context.Web.Lists
$Context.Load($Lists)
$Context.ExecuteQuery()

#Create list with "custom" list template
$ListInfo = New-Object Microsoft.SharePoint.Client.ListCreationInformation
$ListInfo.Title = $ListTitle
$ListInfo.TemplateType = "100"
$List = $Context.Web.Lists.Add($ListInfo)
$List.Description = $ListTitle
$List.Update()
$Context.ExecuteQuery()

#Retrieve site columns (fields)
$SiteColumns = $Context.Web.AvailableFields
$Context.Load($SiteColumns)
$Context.ExecuteQuery()

#Grab city and company fields
$City = $SiteColumns = $Context.Web.AvailableFields | Where {$_.Title -eq "City"}
$Company = $SiteColumns = $Context.Web.AvailableFields | Where {$_.Title -eq "Company"}
$Context.Load($City)
$Context.Load($Company)
$Context.ExecuteQuery()

#Add fields to the list
$List.Fields.Add($City)
$List.Fields.Add($Company)
$List.Update()
$Context.ExecuteQuery()

#Add fields to the default view
$DefaultView = $List.DefaultView
$DefaultView.ViewFields.Add("City")
$DefaultView.ViewFields.Add("Company")
$DefaultView.Update()
$Context.ExecuteQuery()

#Adds an item to the list
$ListItemInfo = New-Object Microsoft.SharePoint.Client.ListItemCreationInformation
$Item = $List.AddItem($ListItemInfo)
$Item["Title"] = "New Item"
$Item["Company"] = "Contoso"
$Item["WorkCity"] = "London"
$Item.Update()
$Context.ExecuteQuery()