function ListAdministrators($Group)
{
  $members= $Group.psbase.invoke("Members") | %{$_.GetType().InvokeMember("Name", 'GetProperty', $null, $_, $null)}
  $members
}
 
function Ping-Server {
   Param([string]$srv)
   $pingresult = Get-WmiObject Win32_PingStatus -Filter  "Address='$srv'"
   if($pingresult.StatusCode -eq 0) {$true} else {$false}
}
 
if ($args.Length -ne 2) {
 Write-Host "`tUsage: "
 Write-Host "`t`t.\AddToLocalAdmin.ps1 < group or user > <file of machines>"
 Write-Host "`t`tExample: .\AddToLocalAdmin.ps1 FooBarGroup c:\temp\mymachines.txt"
 return
}
 
#Your domain, change this
$domain = "PHX"
 
#Get the user to add
$username = $args[0]
 
#File to read computer list from
$strComputers = Get-content $args[1]
 
foreach ($strComputer in $strComputers)
{ 
 
  if (Ping-Server($strComputer)) { 
 
      $computer = [ADSI]("WinNT://" + $strComputer + ",computer")
      $Group = $computer.psbase.children.find("administrators")
      # This will list what’s currently in Administrator Group so you can verify the result
      write-host -foregroundcolor green "====== $strComputer BEFORE ====="
      ListAdministrators $Group
      write-host -foregroundcolor green "====== BEFORE ====="
 
      # Even though we are adding the AD account
      # It is being added to the local computer and so we will need to use WinNT: provider 
 
      $Group.Add("WinNT://" + $domain + "/" + $username) 
 
      write-host -foregroundcolor green "====== $strComputer AFTER ====="
      ListAdministrators $Group
      write-host -foregroundcolor green "====== AFTER ====="
 
   }
   else
   {
      write-host -foregroundcolor red "$strComputer is not pingable"
   }
}