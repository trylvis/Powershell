#Check if path exists
$Path = "C:\Temp\document.txt"
#Dersom fil eksisterer, skriv tekst og opna fil, hvis ikkje skriv feilmld
If (Test-Path $Path) {Write-Host -ForegroundColor Green "Fil found"} else {Write-Host -ForegroundColor Red "Could not find file $Path"}

