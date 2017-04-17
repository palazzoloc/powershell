Function GetServiceInformation()
{

    param
    (
        [String] $ServerName = $(throw "Missing Server Name parameter"),
        [String] $ServiceName = $(throw "Missing Service Name parameter")       

        #Desired state Should be "Running" or "Stopped"
     )
  
       
	$serviceinfo= Get-service -Name $ServiceName -ComputerName $ServerName -ErrorAction SilentlyContinue
    $serviceStatus= $serviceinfo.Status
  
    Write-Host "Service " -NoNewline
    Write-Host "$ServiceName " -ForegroundColor Red -NoNewline
    Write-Host " for " -NoNewline
    Write-Host "$ServerName " -ForegroundColor Green -NoNewline
    Write-Host " is " -NoNewline

    if ($serviceStatus -eq "Running"){ 
    $textColor= "Green"
    } else
    {$textColor= "Red"}
    
    if ([string]::IsNullOrEmpty($serviceStatus)){
    $serviceStatus = " Service Not Available"
    $textColor= "Magenta"
    }
    
    Write-Host "$servicestatus" -ForegroundColor $textColor
 }

###########################
###    Begin Script     ###
###########################

Write-Host ""
$Content = get-content E:\TOOLS\servicelist.txt

$Content | ForEach-Object {
( $SrvrName,$SrvcName) = $_.split(',')

## $SrvrName = Server Name
## $SrvcName = SErvice Name

GetServiceInformation -ServerName $SrvrName -ServiceName $SrvcName

}


