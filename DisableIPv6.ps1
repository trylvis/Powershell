# Function to disable IPv6 on all netadapters

function DisableIPv6 {
    Import-Module NetAdapter
    $netAdapters = Get-NedAdapter
    foreach ($adapter in $netAdapters)
    {
        Get-NetAdapterBinding -Name $adapter.Name | Select-Object Name,DisplayName,ComponentID
        Disable-NetAdapterBinding -Name $adapter.Name -ComponentID ms_tcpip6
        $name = $adapter.Name
        Write-Host -ForegroundColor Green "Disabed IPv6 for NIC: $name "
    }
    }
