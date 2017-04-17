$servername = get-content "serverlist.txt"

## Check server if online
foreach ($Server in $servername) {  
  
        if (test-Connection -ComputerName $Server -Count 2 -Quiet ) {   
          
            "$Server is Pinging "  
         
                    } else  
                      
                    {"$Server not pinging"  
              
                    }      
          
} 


## Check disk space
foreach ($server in $servername)
{
  $disk = ([wmi]"\\$server\root\cimv2:Win32_logicalDisk.DeviceID='c:'") 
  "Drive C: of $server has {0:#.0} GB free of {1:#.0} GB Total" -f ($disk.FreeSpace/1GB),($disk.Size/1GB) | out-file -filepath c:\temp\PreCheckOutput.txt

  write-host $disk

  if ($disk.FreeSpace/1GB -lt 1.7) 
  {
        # Add folders to clean up here:
        $tempfolders = @("\\$server\C$\Windows\Temp\*", "\\$server\C$\msnipak\MSNPATCH\*","\\$server\C$\Windows\Prefetch\*")

        # This line actually removes all items in each folder above. Be careful, this doesn't ask questions, simply forces the removal.
        # if you want to see what it would remove, add -WhatIf in the line below.
        Remove-Item $tempfolders -force -recurse | out-file -FilePath c:\temp\DeletedFilesOutput.txt

        # This line will delete the content based on a set number of days you want to keep (say delete anything older than 30 days).
        # gci “c:\temp\*.*”|? {$_.lastwritetime -lt (get-date).adddays(-30)} | remove-item
		gci “c:\MSNPATCH\*.*”|? {$_.lastwritetime -lt (get-date).adddays(-30)} | remove-item

		# Cleaning up the Windows Update source directory and restarting the SCOM Agent
		net stop HealthService
		net stop wuauserv
		del /f c:\Windows\SoftwareDistribution\DataStore\DataStore.edb
		del /f "C:\Program Files\Microsoft Monitoring Agent\Agent\Health Service State\Health Service Store"
		net start wuauserv
		net start HealthService

        # Comment these lines out if you want to clean the Recycle Bins
		#
        ATTRIB %systemdrive%\RECYCLER\* -R -S -H /S /D
        DEL %systemdrive%\RECYCLER\* /F /S /Q
		# ATTRIB E:\RECYCLER\* -R -S -H /S /D
        # DEL E:\RECYCLER\* /F /S /Q
    }

}

