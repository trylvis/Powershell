#
# Script to find and disable old AD computer objects
# FYI: lastLogonTimestamp is allways 9-14 days behind
#

# Import ActiveDirectory module
Import-Module ActiveDirectory

$DomainCredential = Get-Credential

$DaysInactive = 180
$time = (Get-Date).Adddays(-($DaysInactive))
$TargetOU = "OU=Disabled Servers,OU=Data Center,DC=mydomain,DC=local"

$OldComputers = Get-ADComputer -Filter {lastlogontimestamp -lt $time} -Properties Name,OperatingSystem,lastlogontimestamp,DistinguishedName,ObjectGUID,Enabled | `
Select-Object Name,OperatingSystem,DistinguishedName,ObjectGUID,Enabled,@{N='lastlogontimestamp'; E={[DateTime]::FromFileTime($_.lastlogontimestamp)}} | `
Where-Object OperatingSystem -like *Server* | `
Sort-Object lastlogontimestamp


ForEach ($computer in $OldComputers) {
    if($computer.Enabled -like "True"){
        Write-Host "Disabling object: " $computer.Name 
        Set-ADComputer $computer.ObjectGUID -Description "Computer Disabled on $(Get-Date)" -Enabled $false -Credential $DomainCredential
        Write-Host "Moving object: " $computer.Name 
        Move-ADObject $computer.ObjectGUID -TargetPath $TargetOU -Credential $DomainCredential
    }
}
