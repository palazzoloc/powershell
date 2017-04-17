<#   
Name: remove-ad-group.ps1   
Objective: To read a list of computernames from a file and then if the identified   
group exists in the local administrators group remove it   
Date: 01/31/2011   
Email: rburke@rbconsulting.net  
#>   
#Name of user or group to be removed   
$userName = 'wcs-fese'   
#Name of local group to add user or group to   
$localGroupName = 'Administrators'   
#Variable that contains the contents of the servername list   
$c = Get-Content "E:\WLLNET\SCRIPTS\SPC-Servers.txt"   
#read each name and execute below script against each name in the list   
foreach ($comp in $c)   
{   
#Variable reassignment   
$computerName = $comp   
#This reads the local domain and prepends it to the USERID   
[string]$domainName = ([ADSI]'').name   
# We are providing a yes so that we are not prompted for each computer   
$confirm = "Y"   
if ($confirm -eq "Y") {   
# ([ADSI]"WinNT://$computerName/$localGroupName,group").Add("WinNT://$domainName/$userName")
([ADSI]"WinNT://$computerName/Administrators,group").Add("WinNT://$domainName/$userName")
#We could output this to a file for future reference  
Write-Host "User $domainName\$userName has been added to local group $localGroupName on computer $computerName."   
}   
} 