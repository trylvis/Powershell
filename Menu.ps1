# Simple way of creating a menu in a PowerShell script

function Menu {
    [Int]$Menu= read-host "Choose action: "`n" 1: Install IIS with ASP"`n" 2: Back to menu"`n" 3: Exit"
    switch ($Menu){
        1 {InstallIIS}
        2 {GoToMenu}
        3 {exit}
        }
    }