# Script that collects Windows Update information from servers
# First collect a list of servers based on the $ServersOU variable
# Remotes in to each machine and collects Windows Update data
# Outputs CSV file which can be read from f.x a Web Application or processed as wanted

$ServersOU = "OU=MyOrgUnit,DC=mydomain,DC=ad,DC=com"
$time = (Get-Date).Adddays(-(30))

# Get computers to query from AD
# Using filter with "lastlogontimestamp" to only select servers thats been online for the last x days. 
# Selecting objects where OS contains "server" and computer object is Enabled.
$Servers = Get-ADComputer -Filter {lastlogontimestamp -gt $time} -SearchBase $ServersOU -Properties Name,OperatingSystem,Enabled,MemberOf | `
Where-Object OperatingSystem -like *Server* | `
Where-Object Enabled -EQ $true

# To test the script one can also simply query just one machine, and comment out the $Servers section above:
#$Servers = Get-ADComputer myComputer01 -Properties MemberOf

$sName = "updatestatus"
$outPath = "\\localhost\c$\wustatus\"+$sName

$tmpOutpath = $outPath+"temp.csv"
$lastrunPath = $outPath+"lastRun.csv"
$outPath = $outPath+".csv"
Write-Output "$Date" > $lastrunPath

$Date = Get-Date
$Date = $Date.ToString('dd-MM-yyyy-HH_mm_s')

# The output CSV file always have the same name, so it can easily be read from other sources. Before running the script, the previous version is always renamed.
# Check if out-file already exists, if yes  - rename with days date in the name to make sure newest file allways has the same name
$Name = "$sName"+$Date+".csv"

if(Test-Path $outPath) {Rename-Item -Path $outPath -NewName $Name}
(Get-Content $tmpOutpath) | % {$_ -replace '"', ""} | out-file -FilePath $tmpOutpath -Force -Encoding ascii
    
#Check if out-file already exists, if yes  - rename with days date in the name to make sure newest file allways has the same name


$Credential = Get-Credential
    
$updates = foreach($server in $Servers){
    Write-Host -ForegroundColor Green "Trying to connect to $server"
    #Creating a session against server
    $Session = New-PSSession -ComputerName $server.Name -ErrorAction SilentlyContinue -Credential $Credential
    if($Session)
        {
        #Script thats run on the server
            Write-Host -ForegroundColor Green "Successfully connected to $server, starting to collect update data"
            $GetPending = Invoke-Command -Session $Session -ScriptBlock {
            $updateSession = New-Object -ComObject Microsoft.Update.Session
            $Searcher = $updateSession.CreateUpdateSearcher()
            $PendingUpdates = $Searcher.Search("IsInstalled=0 and Type='Software' and IsHidden=0")
            $PendingUpdates = $PendingUpdates.Updates
            $Installed = $Searcher.QueryHistory(1,1) | Select-Object -ExpandProperty Date
            $LastBootTime = Get-WmiObject win32_operatingsystem | Select-Object Caption, @{LABEL='LastBootUpTime' ;EXPRESSION={$_.ConverttoDateTime($_.lastbootuptime)}}
            New-Object pscustomobject -Property @{
            Server = ""
            Pending = $PendingUpdates.Count
            LastInstalled = $Installed.Date.ToString('dd-MM-yyy')
            Accessible = $true
            LastBootTime = $LastBootTime.LastBootUptime
            OperatingSystem = $LastBootTime.Caption
            MemberOf = ""
            } 
            Exit
            }
        }
        else
        {
        Write-Warning "$server not accessible"
        $GetPending = New-Object pscustomobject -Property @{Accessible = $false ; Server=$server.Name}
        }


        if($GetPending.Accessible -eq $true)
        {
            $lastInstalled = $GetPending.LastInstalled
            if($GetPending.Pending -gt 0)
            {
            $countMessage = $GetPending.Pending.ToString();
            $countMessage = $countMessage + " pending updates"
            } 
            else 
            {
            $countMessage = "No pending updates"
            }

            Write-Host -ForegroundColor Green "$server = $countMessage. The latest updates was installed $lastInstalled"
            Write-Output "$server = $countMessage. The latest updates was installed $lastInstalled" > $logPath

        }
        $GetPending.MemberOf = $server.MemberOf
        $GetPending.Server = $server.Name
        $GetPending | Select-Object Server,Accessible,Pending,LastInstalled,LastBootTime,OperatingSystem,@{name=”MemberOf”;expression={$_.memberof -join “;”}} | Export-Csv $tmpOutpath -Append -NoTypeInformation
    }


    Rename-Item $tmpOutpath $outPath