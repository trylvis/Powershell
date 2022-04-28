$compName = "my-dc-001"
Do {
    
    Write-Host "$compName is Offline"
    Start-Sleep 1
   
}
Until (Test-Connection -ComputerName $compName -Quiet -Count 2)
Write-Host "$compName is Online"