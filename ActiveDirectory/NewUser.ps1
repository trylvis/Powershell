##################################
# Author Tarjei Nagell Ylvisåker #
# Date 22.05.2020                #
##################################


#############################################################################
######################       Enviroment Variables      ######################
#############################################################################
$companyName = "MyCompany"
$companyCode = "MC"
$country = "IS"
$mailDomain = "mycompany.com"
$adGroups = @("All-MyCompany")

#############################################################################
######################         Check dependencies      ######################
#############################################################################
Write-Host -ForegroundColor Green "Checking dependencies"
Write-Host -ForegroundColor Green ".."


#Check if ActiveDirectory-module for PowerShell is installed
Write-Host -ForegroundColor Green "Checking if ActiveDirectory Powershell-Modul is installed.."
Write-Host -ForegroundColor Green ".."
if(Get-Module -ListAvailable | Where-Object -Property Name -like 'ActiveDirectory'){
Write-Host -ForegroundColor Green "OK: ActiveDirectory-modul for PowerShell is installed"
} 
else{
Write-Warning "ActiveDirectory-modul for PowerShell is not installed"
Write-Warning ".."
Write-Warning "Stopping script"
exit
}
Write-Host -ForegroundColor Green ".."



#############################################################################
##########################       Collect data      ##########################
#############################################################################
Write-Host -ForegroundColor Green ".."
Write-Host -ForegroundColor Green "Start collecting data"
Write-Host -ForegroundColor Green ".."
#Collect Givenname and surname with validation
do
{
   $firstname = read-host -prompt "Enter Firstname (t.d. Jón Dagur)" 
}
until (![string]::IsNullOrWhiteSpace($firstname))
do
{
   $lastname = read-host -prompt "Enter Lastname (t.d. Jónsson)" 
}
until (![string]::IsNullOrWhiteSpace($lastname))

#Collect username and check that it does not already exist
do
{
    $username = Read-Host -Prompt "Enter username (t.d. tny)"
    if (![string]::IsNullOrWhiteSpace($username)) 
        {
        Write-Host -ForegroundColor Green "Checking that $username is available in AD.."
        if ((Get-ADUser -filter * | Where-Object -Property SaMAccountName -eq $username) -eq $Null) 
             {Write-Host -ForegroundColor Green ".."
              Write-host -ForegroundColor Green "Username is available in AD"} 
        else {Write-host -ForegroundColor Red "Username $username is already in use - please choose a different username"
              $username = $null }
        } 
    else {Write-Host -ForegroundColor Red "Enter username"}
}
until (![string]::IsNullOrWhiteSpace($username))

#Collect UserPrincipalName and make sure it doesn't already exist
do
{
    $UPN = Read-Host -Prompt "Enter name to be used for UserPrincipalName (t.d. Jon.D.Jonsson) - No special characters or icelandic characters allowed"
    if (![string]::IsNullOrWhiteSpace($UPN)) 
        {
        Write-Host -ForegroundColor Green "Checking that" $UPN@$mailDomain "is available in AD.."
        if ((Get-ADUser -filter * | Where-Object -Property UserPrincipalName -eq ($UPN + "@" + $mailDomain)) -eq $Null) 
             {Write-Host -ForegroundColor Green ".."
              Write-host -ForegroundColor Green "UPN is available in AD"} 
        else {Write-host -ForegroundColor Red "UPN $UPN is already in use - please choose a different UPN name"
              $UPN = $null }
        } 
    else {Write-Host -ForegroundColor Red "Enter UPN"}
}
until (![string]::IsNullOrWhiteSpace($UPN))


#Select location. Will not continue before a department is choosen
do
    {
    [Int]$dpt=read-host "Choose location: "`n" 1: North"`n" 2: West"`n" 3: South"`n" 4: East"`n" 5: Middle"`n" 6: Remote"
    switch ($dpt)
    {
	    1 {$location="North"
        $adOU="MyCompany.is/MyCompany/North/Notendur"	
        #$adGroups += ''
        }

	    2 {$location="West"
        $adOU="MyCompany.is/MyCompany/West/Notendur"	
        #$adGroups += ''
        }

	    3 {$location="South"
        $adOU="MyCompany.is/MyCompany/South/Notendur"	
        #$adGroups += ''
        }

	    4 {$location="East"
        $adOU="MyCompany.is/MyCompany/East/Notendur"	
        #$adGroups += ''
        }

	    5 {$location="Middle"
        $adOU="MyCompany.is/MyCompany/Middle/Notendur"	
        #$adGroups += ''
        }

	    6 {$location="Remote"
        $adOU="MyCompany.is/MyCompany/Remote/Notendur"	
        #$adGroups += ''
        }
    } 
   
    }
until ($dpt -ge "1" -and $dpt -le "6")



#Prompt for Title
$title = read-host -prompt "Enter Title (t.d. Manager, Developer)"

#Prompt for Department
$department = Read-Host -Prompt "Enter Department (t.d. Development)"

#Prompt for Division
$division = Read-Host -Prompt "Enter Division (t.d. IT)"

#Prompt for Office
$office = Read-Host -Prompt "Enter Office (t.d. F21, 5th floor)"



#Prompt for emplyees social security number
$socialSecurity = Read-Host -Prompt "Enter social security number (Kennitala, t.d. 111111-1111)"

#Prompt for EmployeeID 
$employeeId = Read-Host -Prompt "Enter Employee ID (t.d. MC-1234)"




#Mobilephone, check if input is nr and add format number like +354 123 4567
$mobTitle = "Mobilephone confirmation"
$message = @"
Do you want to register a mobilephone number for the user?
"@


$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "I don´t want to register mobilephone number now"
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "I want to register a mobilephone number now"
$options = [System.Management.Automation.Host.ChoiceDescription[]]($no, $yes)
$result = $host.ui.PromptForChoice($mobTitle, $message, $options, 0)
switch ($result)
    {
        0 {}
        1 {
        do{
            $Mobinput = read-host -prompt "Enter mobilephone number (7 numbers - no spaces - +354 will be added automatically)"
            #If input is not integer, try to convert to integer
            if ($Mobinput -isnot [int]){$Mobinput = [int]$Mobinput} 
        }
        until ([string]::IsNullOrWhiteSpace($Mobinput) -or $Mobinput -is [int])  
        if ($Mobinput -like "0"){
            Remove-Variable -Name $Mobinput
            [string]$Mobinput = "" 
        }
        if (![string]::IsNullOrWhiteSpace($Mobinput)) {
            $Mobinput = $Mobinput.ToString()
            #Adjust number to match syntax "+354 111 1111"
            $mobilenumber = "+354 " + $Mobinput[0] + $Mobinput[1] + $Mobinput[2] + " " + $Mobinput[3]+ $Mobinput[4]+ $Mobinput[5]+ $Mobinput[6] }
        }
    }


#Work phone, check if input is nr and add format number like +354 123 4567
$phoneTitle = "Workphone confirmation"
$message = @"
Do you want to register a work phone number for the user?
"@


$no = New-Object System.Management.Automation.Host.ChoiceDescription "&No", `
    "I don´t want to register work phone number now"
$yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", `
    "I wan't to register a work phone number now"
$options = [System.Management.Automation.Host.ChoiceDescription[]]($no, $yes)
$result = $host.ui.PromptForChoice($phoneTitle, $message, $options, 0)
switch ($result)
    {
        0 {}
        1 {
        do{
            $Phoneinput = read-host -prompt "Enter work phone number (7 numbers - no spaces - +354 will be added automatically)"
            #If input is not integer, try to convert to integer
            if ($Phoneinput -isnot [int]){$Phoneinput = [int]$Phoneinput} 
        }
        until ([string]::IsNullOrWhiteSpace($Phoneinput) -or $Phoneinput -is [int])  
        if ($Phoneinput -like "0"){
            Remove-Variable -Name $Phoneinput
            [string]$Phoneinput = "" 
        }
        if (![string]::IsNullOrWhiteSpace($Phoneinput)) {
            $Phoneinput = $Phoneinput.ToString()
            #Adjust number to match syntax "+354 111 1111"
            $telephoneNumber = "+354 " + $Phoneinput[0] + $Phoneinput[1] + $Phoneinput[2] + " " + $Phoneinput[3]+ $Phoneinput[4]+ $Phoneinput[5]+ $Phoneinput[6] }
        }
    }




#Prompt for manager, and check if manager exist in AD
do
{
    $manager = Read-Host -Prompt "Enter the username of manager (t.d. johhnyb)"
    if (![string]::IsNullOrWhiteSpace($manager)) 
        {
        Write-Host -ForegroundColor Green "Checking if the username $manager exists..."
        if ((Get-ADUser -filter * | Where-Object -Property SaMAccountName -eq $manager) -eq $Null) 
             {write-host -ForegroundColor Red "Could not find $manager i AD"
              $managerExist = $false
              } 
        else {
              $managerExist = $true
              $managerName = Get-ADUser -Identity $manager | Select-Object -Property Name
              $managerName = $managerName.Name
              write-host -ForegroundColor Green "Manager is set to $managerName"
              }
        } 
}
until ([string]::IsNullOrWhiteSpace($manager) -or $managerExist -eq $true)


#Select M365 subscription
do
    {
    [Int]$m365=read-host "Choose M365 Subscription: "`n" 1: M365 E3 (default)"`n" 2: M365 F1"`n" 3: M365 E5"`n" 4: No M365 Subscription"
    switch ($m365)
    {
        1 {$adGroups += 'Sec-Application-Office 365 E3 standard'
        }

	    2 {$adGroups += 'SEC-Application-Office 365 F1 Standard'
        }

	    3 {$adGroups += 'SEC-Application-Office 365 E5 Standard'
        }

	    4 {
        }
    } 
   
    }
until ($m365 -ge "1" -and $m365 -le "4")



#Fix variables before creating username
$firstname = $firstname.Trim();
$lastname = $lastname.Trim();
$name = $firstname+" "+$lastname
$userPrincipalName = $UPN + '@' + $mailDomain
$remoteRoutingAddress = $companyCode + '-' + $UPN + '@mycompany.mail.onmicrosoft.com'
$mailNickname = $companyCode + '-' + $UPN
$proxyAddresses = "smtp:"+$username+"@mycompany.is,smtp:"+$username+"@mycompany.com"

#Prompt temporary password
$accountpassword = read-host -assecurestring -prompt "Enter temporary password - Minimum 10 chars, Upper/Lowercase and numbers"



#############################################################################
#######################                               #######################
#######################        Collection done        #######################
#######################              ###              #######################
#######################   Starting to configure user  #######################
#######################                               #######################
#############################################################################

#Create user 
New-RemoteMailbox -DisplayName $name -Alias $mailNickname -PrimarySmtpAddress $userPrincipalName -RemoteRoutingAddress $remoteRoutingAddress -UserPrincipalName $userPrincipalName -SamAccountName $username -FirstName $firstname -LastName $lastname -OnPremisesOrganizationalUnit $adOU -Name $name -Password $accountpassword -ResetPasswordOnNextLogon $true 

#Pause in 30 seconds for AD
Write-Host -Foregroundcolor Green "Pause in 30 seconds for AD update"
Start-Sleep -s 30 

#Setting attributes
Get-ADUser $username | Set-ADUser -Country $country -Company $companyName -Title $title -Manager $manager -Department $department -Division $division -Office $office -Description $division -MobilePhone $mobilenumber -OfficePhone $telephoneNumber -EmployeeID $employeeId

#Set location and extensionattributes
Get-ADUser $username | Set-ADUser -Add @{l = $location;extensionAttribute14 = $companyCode;extensionAttribute1 = "$socialSecurity"}
#Get-ADUser $username | Set-ADUser -Add @{extensionAttribute1 = $socialSecurity}

#Add mail aliases from $proxyAddresses
Get-ADUser $username | Set-ADUser -Add @{ProxyAddresses="$proxyAddresses" -split ","}

Write-Host -Foregroundcolor Green "60 sec pause for DC replication"
Start-Sleep -s 60


#Add users to group
foreach ($group in $adGroups){
    Write-Host -ForegroundColor Green "Adding user to the group $group"
    Add-ADGroupMember $group -Members $username
}


Write-Host -foregroundcolor Green "Pausing in 30 seconds for AD updates, followed by a summary of the user. You may go ahead and close this window now"
Start-Sleep -s 30

Write-Host -ForegroundColor Green "Mailbox summary : " 

Get-RemoteMailbox -Identity $username | Format-List

exit