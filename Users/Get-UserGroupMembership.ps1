Import-Module MSONline
#Obtain Credentials and Authenticate to Azure AD
$Username = Read-Host -Prompt "Enter your username"
$Password = Read-Host -Prompt "Enter your password" -AsSecureString
$Cred = New-Object System.Management.Automation.PSCredential $Username, $Password
Connect-MsolService -Credential $Cred

$User = Read-Host -Prompt "Enter user e-mail address of user to obtain group membership for"
Write-Host "$User is a member of the following groups:" -ForegroundColor Green 
Foreach ($MSOLGroup in (Get-MsolGroup))
{
If (Get-MsolGroupMember -GroupObjectId $MSOLGroup.ObjectId | Where {$_.EmailAddress -eq $User})
    {
    Write-Host "-" $MSOLGroup.DisplayName -ForegroundColor Yellow
    }
}