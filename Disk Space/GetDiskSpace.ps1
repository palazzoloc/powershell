$Param = $args[0]


#Count the number of Machines passed, if using a comma
$ArrayCount = $Param.count

if ($ArrayCount -eq 0) { 
	Write-Host " "
	Write-Host "Please enter a file or a servername/s delimited by a comma"
	Write-Host "Exiting..... "
	Write-Host " "
	exit
	}

if (($ArrayCount -eq 1) -and ($Param.Contains(".txt")))
  {
   #check if file exists
   if (Test-Path $Param)
   {
	Write-Host "Getting server list from $Param" `r
	$Content = get-content $Param
   }
   else
      {
	    Write-host "Filename $Param does not exist"`r
	    exit
      }
  }
else
  {
    $Content=$Param
  }


## Check server if online
write-host " "
write-host "Checking if server is responding..."

foreach ($Server in $Content) {  
  
        if (test-Connection -ComputerName $Server -Count 2 -Quiet ) {   
          
            "$Server is Pinging "  
          
                    } else  
                      
                    {"$Server not pinging"  
              
                    }      
          
} 

write-host " "
write-host "Checking Disk space of C:| drive of servers..."
write-host " "
foreach ($server in $Content)
{
  $disk = ([wmi]"\\$server\root\cimv2:Win32_logicalDisk.DeviceID='c:'") 
  "Drive C: of $server has {0:#.0} GB free of {1:#.0} GB Total" -f ($disk.FreeSpace/1GB),($disk.Size/1GB) | write-output
}
