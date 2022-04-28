# Function to rename a server / client
function SetComputerName{
    $computerName = Get-WmiObject Win32_ComputerSystem
    $CompName= Read-Host -Prompt "Enter the computername"
    $computerName.Rename($CompName)
    
    Write-Host -foregroundcolor Green "Computername is changed to $CompName , this will take effect after restart."
    }