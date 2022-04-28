# Function to install IIS with some base functionality

function InstallIIS {
    Import-Module ServerManager
    Add-WindowsFeature Web-Server, Web-Asp-Net
}