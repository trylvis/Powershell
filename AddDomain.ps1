# Function to add a server / client to the domain
function AddDomain {
    $domain = read-host -prompt "Enter the name of the domain - include .local / .com " # ex ad.mydomain.local
    $user = read-host -Prompt "Enter username without domain prefix - myuser not ad.mydomain.local\myuser"
    $password = Read-Host -Prompt "Enter the password for $user" -AsSecureString 
    $username = "$domain\$user" 
    $credential = New-Object System.Management.Automation.PSCredential($username,$password) 
    Add-Computer -DomainName $domain -Credential $credential
}