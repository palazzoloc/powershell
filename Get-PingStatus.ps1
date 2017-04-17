
#get-pingstatus
# accepts an array of machine names or a file of machine names
# displays up / down status using ping test
# updates every x seconds
#
#
### get-pingstatus $computerarray -reboot
#
#  Computer  LastPinged  DownAsOf  BackOnlineAt  PingResponse
#  --------  ----------  --------  ------------  -------------
#  Host1     1/1 1pm     1:15pm    1:20pm        Reply from Host1....
#  H2        Never 
#  H3        1/1 1:15pm  1:16pm                  Destination not found
#  H4        1/1 1:14pm                          Reply from Host1..
#
#
### get-pingstatus $computerarray
#  Computer  LastPinged  PingResponse
#  --------  ----------  -------------
#  Host1     1/1 1pm     Reply from Host1....
#
[CmdletBinding()] 
param( 
  [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)] 
  [Alias("CN","Computer")] 
  [String[]]$ComputerArrayOrFile,
  [bool]$AutoRefresh=$true,
  [int]$RefreshInSeconds=30
  )
  
Begin 
{
	$TempErrAct = $ErrorActionPreference 
	$ErrorActionPreference = "SilentlyContinue" 
	
	function Check-PingStatusAndShowTable( $computertable )
	{
		#Get up down status
		foreach ($computer in $computertable)
		{
			$response = ping -n 1 $computer.Computer
			if (($response | findstr /i "Reply from" | select -first 1) -ne $null)
			{
				$computer.LastPinged = (get-date)
				$computer.PingResponse = $response | findstr /i "Reply from" | select -first 1
			}
			elseif (($response | findstr /i "Request timed out" | select -first 1) -ne $null)
			{
				$computer.PingResponse = $response | findstr /i "Request timed out" | select -first 1
			}
			else
			{
				$computer.PingResponse = $response
			}
		}
		$computertable | select Computer, LastPinged, PingResponse | ft -a
	}

}
Process 
{
	$Computers = @()

	if (($ComputerArrayOrFile -eq $null) -or ($ComputerArrayOrFile -eq ""))
	{
		write-host "Usage: get-pingstatus (get-content hosts.txt) -reboot"
		exit
	}
	elseif(($ComputerArrayOrFile.Count -eq 1) -and (test-path $ComputerArrayOrFile))
	{
		$Computers += get-content $ComputerArrayOrFile
	}
	else 
	{
		$Computers += $ComputerArrayOrFile
	}
		
	$computertable = @()
	$tablefields = @{ Property=('Computer','LastPinged','DownAsOf','BackOnlineAt','PingResponse') } 
	foreach ($Computer in $Computers)
	{
		$computertable += New-Object -TypeName PSObject -Property @{ 
							 Computer=$Computer
							 LastPinged="Never"
							 DownAsOf=""
							 BackOnlineAt=""
							PingResponse=""
						} | Select-Object @tablefields
	}
	
	## $computertable = RestoreTableIfHostnamesMatch

	if ($AutoRefresh)
	{
		While ($true)
		{
			Check-PingStatusAndShowTable( $computertable )
			
			write-host "Ctrl C to exit"
			sleep $RefreshInSeconds
		}
	}
	else
	{	
		# Loop until stopped by any key except enter
		Do
		{
			Check-PingStatusAndShowTable( $computertable )
		} 
		While ((Read-Host "Press enter to continue. Ctrl C or any text will exit.") -eq "")
	}
}
End 
{ 
	# Resetting ErrorActionPref 
	$ErrorActionPreference = $TempErrAct 
}
