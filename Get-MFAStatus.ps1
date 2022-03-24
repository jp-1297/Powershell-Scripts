#>


# Requires MSOL Module from PSRepository

<#To generate a password file to automate the 365 login, use this command:
"365password" | ConvertTo-SecureString -AsPlainText -Force | ConvertFrom-SecureString | Out-File "Whatever\File\Path\textdoc.txt"
The txt file can only be read by the  user account that created it, so this script will only work under the user account that created the encrypted text file.
#>
#Generate PSCredential for Office 365
$csvpath = "Path to export CSV file"
$user = "Put the email address of the admin user"
$file = "Path to secure txt file of admin password"
$Admin = New-Object -TypeName System.Management.Automation.PSCredential -ArgumentList $user, (Get-Content $file | ConvertTo-SecureString)



Connect-MSOLService -credential $Admin

#Get all enabled users that are licensed, but do not have MFA turned on, and aren't part of the exemption list
$users = get-msoluser -enabledfilter EnabledOnly -all |
Where-Object { $_.islicensed -eq $true } |
Select-Object DisplayName, @{ N = 'Email'; E = { $_.UserPrincipalName } }, @{ N = 'MFAEnabled'; E = { if ($_.StrongAuthenticationRequirements) { Write-Output $true }
		else { Write-Output $false } } }

$users | Export-Csv -NoTypeInformation -Path "$csvpath\MFAStatus.csv"
