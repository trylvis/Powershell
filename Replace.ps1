$Firstname = read-host -prompt "Enter firstname"
$Lastname = read-host -prompt "Enter surname"
   

if ($Firstname.Contains(" ")) {
    $email = $Firstname -replace " ","."
}
$email = $email+"."+$Lastname

$email

   
   