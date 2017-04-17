# ---------- SCRIPT STARTS HERE--------------

$inputfile = Dir $args[0]
 $readinputfile = get-content $inputfile
 $readinputfile | ForEach-Object { 

$objsystem = get-wmiobject -computername $_ -query "select * from win32_operatingsystem"
 $result = $objsystem.shutdown()

if ($result.returnvalue -match "0") {
 write-host "$_ - shutdown command completed" -foregroundcolor green
 }
 else {
 write-host "$_ - unable to send shutdown command" -foregroundcolor red
 }


}

# ---------- SCRIPT ENDSS HERE--------------
