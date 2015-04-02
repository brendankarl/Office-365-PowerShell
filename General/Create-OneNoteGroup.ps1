$Username = "admin@tenant.onmicrosoft.com"
$Site = "https://tenant.sharepoint.com/sites/sitetocreategroupwithin"
$Password = Read-Host -Prompt "Please enter your password" -AsSecureString
$PermName = "OneNote Class Notebook Authors"
$PermDescription = "OneNote Class Notebook Authors"

#Add references to SharePoint client assemblies and authenticate to Office 365 site
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.dll"
Add-Type -Path "C:\Program Files\Common Files\Microsoft Shared\Web Server Extensions\16\ISAPI\Microsoft.SharePoint.Client.Runtime.dll"

$Context = New-Object Microsoft.SharePoint.Client.ClientContext($Site)
$Creds = New-Object Microsoft.SharePoint.Client.SharePointOnlineCredentials($Username,$Password)
$Context.Credentials = $Creds

$Web = $Context.Web
$Context.Load($web)
$permissionlevel = "ManageLists, CancelCheckOut, AddListItems, EditListItems, DeleteListItems, ViewListItems, ApproveItems, OpenItems, ViewVersions, DeleteVersions, CreateAlerts, ViewFormPages, ManagePermissions, BrowseDirectories, ViewPages, EnumeratePermissions, BrowseUserInfo, UseRemoteAPIs, Open"
$RoleDefinitionCol = $web.RoleDefinitions
$Context.Load($roleDefinitionCol)
$Context.ExecuteQuery()
$permExists = $false
$spRoleDef = New-Object Microsoft.SharePoint.Client.RoleDefinitionCreationInformation
$spBasePerm = New-Object Microsoft.SharePoint.Client.BasePermissions
$permissions = $permissionlevel.split(",");
foreach($perm in $permissions){$spBasePerm.Set($perm)}

$spRoleDef.Name = $permName
$spRoleDef.Description = $permDescription
$spRoleDef.BasePermissions = $spBasePerm    
$roleDefinition = $web.RoleDefinitions.Add($spRoleDef)
$Context.ExecuteQuery()

#Retrieve Groups
$Groups = $Context.Web.SiteGroups
$Context.Load($Groups)
$Context.ExecuteQuery()

#Create Group
$NewGroup = New-Object Microsoft.SharePoint.Client.GroupCreationInformation
$NewGroup.Title = $PermName
$NewGroup.Description = $PermDescription
$OneNoteGroup = $Context.Web.SiteGroups.Add($NewGroup)

#Retrieve Permission Level
$PermissionLevel = $Context.Web.RoleDefinitions.GetByName($PermDescription)

#Bind Permission Level to Group
$RoleDefBind = New-Object Microsoft.SharePoint.Client.RoleDefinitionBindingCollection($Context)
$RoleDefBind.Add($PermissionLevel)
$Assignments = $Context.Web.RoleAssignments
$RoleAssignOneNote = $Assignments.Add($OneNoteGroup,$RoleDefBind)
$Context.Load($OneNoteGroup)
$Context.ExecuteQuery()