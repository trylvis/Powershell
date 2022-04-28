##Variables:
Set-Variable snmpIp "ApprovedIP" -scope script    #Approved IP for SNMP
Set-Variable commstring "myCommunityString" -scope script    #SNMP Community String

##Install SNMP and set community string and approved ip
function InstallSNMP {
#Import servermanager
Import-Module ServerManager
 
#Check if SNMP is installed - if not install it
$check = Get-WindowsFeature | Where-Object {$_.Name -eq "SNMP-Services"}
If ($check.Installed -ne "True") {
        #Install SNMP
        Add-WindowsFeature SNMP-Services | Out-Null
} else {Write-Host -foregroundcolor Green "SNMP er allereie installert"}

 
##Verify that SNMP is installed
If ($check.Installed -eq "True"){
        #Add SNMP ip **This will overwrite existing SNMP registry settings**
        reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /v 1 /t REG_SZ /d localhost /f | Out-Null
        $i = 2
        Foreach ($manager in $snmpIp){
                reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\PermittedManagers" /v $i /t REG_SZ /d $manager /f | Out-Null
                $i++
                }
        #Legg til SNMP Community String
        Foreach ( $string in $commstring){
                reg add "HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\services\SNMP\Parameters\ValidCommunities" /v $string /t REG_DWORD /d 4 /f | Out-Null
                }
}
Else {Write-Host -foregroundcolor Red "Error: SNMP was not installed"}
}
