# Simple way to ask for confirmation to continue in a script

$title= "Confirmation"
$message = @"
This will set the following settings:

xx

Do you want to continue?
"@

$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "Helptext Yes."
$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "Helptext No."
$options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
$result = $host.ui.PromptForChoice($title, $message, $options, 0)

switch ($result)
    {
        0 {Write-Host "Yes"          }
        1 {Write-Host "No"}
    }
