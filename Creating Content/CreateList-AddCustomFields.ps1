#Add references to SharePoint client assemblies and authenticate to Office 365 site
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"
$Username = ""
$Site = ""
$ListTitle = "CustomList"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)
$Context.Credentials = $Creds

#Create List
$ListInfo = New-Object Microsoft.SharePoint.Client.ListCreationInformation
$ListInfo.Title = $ListTitle
$ListInfo.TemplateType = "100"
$List = $Context.Web.Lists.Add($ListInfo)
$List.Description = $ListTitle
$List.Update()
$Context.ExecuteQuery()

#Add Questions
#Question - Multiple Lines of Text
$List.Fields.AddFieldAsXml("<Field Type='Note' NumLines='6' DisplayName='Question'/>",$true,[Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldToDefaultView)
$List.Update()
$Context.ExecuteQuery()

#Answer - Enhanced Rich Text
$a = $List.Fields.AddFieldAsXml("<Field Type='Note' RichText='TRUE' RichTextMode='FullHtml' DisplayName='Answer'/>",$true,[Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldToDefaultView)
$a = $List.Update()
$a = $Context.ExecuteQuery()

#Question Type - Choice
$a = $List.Fields.AddFieldAsXml("<Field Type='Choice' DisplayName='QuestionType'>
                            <CHOICES>
                                <CHOICE>Office 365</CHOICE>
                                <CHOICE>General</CHOICE>
                                <CHOICE>Email</CHOICE>
                                <CHOICE>OneDrive</CHOICE>
                                <CHOICE>sharePoint</CHOICE>
                                <CHOICE>Office Apps</CHOICE>
                                <CHOICE>Office Online</CHOICE>
                                <CHOICE>Other</CHOICE>
                            </CHOICES></Field>",$true,[Microsoft.SharePoint.Client.AddFieldOptions]::AddFieldToDefaultView)
$List.Update()
$Context.ExecuteQuery()