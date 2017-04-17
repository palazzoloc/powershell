## Author: Adam Bacon Created on: 01/03/2011   
## Scripted in: Powershell will work in V1&2   
## Purpose: To automate server or desktop share size  information. Using WMI & powershell   
## Will work on any machine, no matter make or model.    
## Modified: 14/03/11 Added a trap incase you dont have permissions to folders, saves the red errors   
## on screen, also added force parameter on searching   
## Modified: 02/04/11 Took advice from Ben Wilkinson and removed a few lines of the original code  

$DebugPreference = "Continue"   
Write-Debug "Gathering share information"   
Write-Debug "About to commence searching through all shares, please wait"   
function folder-size {   
BEGIN{}                   
PROCESS{   
Trap{ Write-Host -foreground Yellow -background Black "WARNING $_"   
      Continue   
    }   
    Write-Host "Processing Share $_ ..."   
    set-location "$_"   
    get-childitem | where {$_.PSIsContainer} | foreach {$size = (Get-ChildItem "$_" -force -recurse -ErrorAction Stop | where {!$_.PSIsContainer} | Measure-Object -Sum Length).Sum   
$obj = new-object psobject       
add-Member -InputObject $obj noteproperty "Folder Name" $_.name   
add-member -InputObject $obj noteproperty "Folder Path" $_.fullName   
add-member -InputObject $obj noteproperty "Folder Size" ("{0:N2}" -f ($size /1GB)+"GB")   
Write-Output $obj | sort "Folder Size" -Descending                                                            }                                                                }   
END{}   
}   
$shares = Get-WmiObject -Class Win32_Share | where {($_.Path).length -gt 3} | foreach {$_.path} 
$shares | folder-size | Sort-Object "Folder Size" -Descending | Export-Csv C:\FldrSize.csv   
Write-Debug "Script has finished running"  
