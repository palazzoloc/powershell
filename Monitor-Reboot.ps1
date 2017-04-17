#Monitor-Reboot
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
[CmdletBinding()] 
param( 
  [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)] 
  [Alias("CN","Computer")] 
  [String[]]$ComputerArrayOrFile,
  [bool]$AutoRefresh=$true,
  [int]$RefreshInSeconds=30,
  [bool]$IgnoreCache=$false
  )
  
Begin 
{
	$TempErrAct = $ErrorActionPreference 
	$ErrorActionPreference = "Inquire" 
	$cachefilename = "monitor-reboot.cache.csv"
	
	function RestoreTable
	{
		return import-csv -path $cachefilename
	}
	
	function SaveTable( $computertable )
	{
		$computertable | export-csv -path $cachefilename
	}
	
	function RestoreTableIfListIsTheSame( $computertable )
	{

		if (test-path $cachefilename)
		{
			$tablefromfile = RestoreTable
			
			if ($tablefromfile.Count -ne $computertable.Count)
			{
				Write-Host "List length changed. Ignoring cache."
				return $computertable
			}	


			$completematch = $true
			foreach ($tablerow in $computertable)
			{
				$rowmatched = $false
				foreach ($filerow in $tablefromfile)
				{
					if ($filerow.Computer -eq $tablerow.Computer)
					{
						$rowmatched = $true
					}
				}
				if ($rowmatched -eq $false)
				{
					Write-Host "List changed. Ignoring cache."
					return $computertable
				}
			}
			if ($completematch)
			{
				write-host "List is unchanged. Using $cachefilename"
				return $tablefromfile
			}
		}
		return $computertable
	}
	
	function Track-RebootAndShowTable( $computertable )
	{
		#Get up down status
		foreach ($computer in $computertable)
		{
			# Stage 3, back online
			if ($computer.BackOnlineAt -ne "")
			{
				continue # cause this one is done
			}
			else
			{
				$response = ping -n 1 $computer.Computer
				
				# Stage 1, online and waiting for down
				if ($computer.DownAsOf -eq "")
				{
					# Positive indicator of online, not yet downed
					if (($response | findstr /i "Reply from" | select -first 1) -ne $null)
					{
						$computer.LastPinged = (get-date)
						$computer.PingResponse = $response | findstr /i "Reply from" | select -first 1
					}
					elseif (($response | findstr /i "Request timed out" | select -first 1) -ne $null)
					{
						$computer.DownAsOf = (get-date)
						$computer.PingResponse = $response | findstr /i "Request timed out" | select -first 1
					}
					else # down
					{
						$computer.DownAsOf = (get-date)
						$computer.PingResponse = $response
					}
				} # Stage 2, downed and waiting for online
				elseif ($computer.DownAsOf -ne "" -and $computer.BackOnlineAt -eq "")
				{
					# Positive indicator of online, back online
					if (($response | findstr /i "Reply from" | select -first 1) -ne $null)
					{
						$computer.BackOnlineAt = (get-date)
						$computer.PingResponse = $response | findstr /i "Reply from" | select -first 1
					}
					elseif (($response | findstr /i "Request timed out" | select -first 1) -ne $null)
					{
						$computer.PingResponse = $response | findstr /i "Request timed out" | select -first 1
					}
					else # still down
					{
						$computer.PingResponse = $response
					}
				} 
			}
		}
		$computertable | Select @tablefields | ft -a
	}

}
Process 
{
	$Computers = @()

	if (($ComputerArrayOrFile -eq $null) -or ($ComputerArrayOrFile -eq ""))
	{
		write-host "Usage: monitor-reboot hosts.txt"
		write-host "Usage: monitor-reboot 'host1','host2'"
		exit
	}
	elseif(($ComputerArrayOrFile.Count -eq 1) -and (test-path $ComputerArrayOrFile))
	{
		$Computers += get-content $ComputerArrayOrFile
		Write-Host "Found file $ComputerArrayOrFile"
		$Computers
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
#write-host "Before"
#$computertable
#$computertable.Count
	if ($IgnoreCache -eq $false)
	{
		$computertable = RestoreTableIfListIsTheSame $computertable
	}
#write-host "After"
#$computertable
#$computertable.Count
#Read-Host
	if ($AutoRefresh)
	{
		While ($true)
		{
			Track-RebootAndShowTable( $computertable )
			
			SaveTable $computertable 
			
			write-host "Ctrl C to exit"
			sleep $RefreshInSeconds
		}
	}
	else
	{	
		# Loop until stopped by any key except enter
		Do
		{

			Track-RebootAndShowTable( $computertable )
			
			SaveTable $computertable 
		} 
		While ((Read-Host "Press enter to continue. Ctrl C or any text will exit.") -eq "")
	}
}
End 
{ 
	# Resetting ErrorActionPref 
	$ErrorActionPreference = $TempErrAct 
}
