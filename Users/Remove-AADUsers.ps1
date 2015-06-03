Import-Module MSONline
#Obtain Credentials and Authenticate to Azure AD
$Username = Read-Host -Prompt "Enter your username"
$Password = Read-Host -Prompt "Enter your password" -AsSecureString
$Cred = New-Object System.Management.Automation.PSCredential $Username, $Password
Connect-MsolService -Credential $Cred

#Update "user*" with the value you require, all users matching this criteria will be deleted from Azure AD

$Users = Get-MsolUser | where {$_.UserPrincipalName -like "user*"}
$Users | ForEach-Object {Remove-MsolUser -UserPrincipalName $_.userprincipalname -Force}
