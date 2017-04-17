#shutdown-thesemachines
# accepts an array of machine names or a file of machine names
# sends reboot command to each machine in a list
#
#
### reboot-thesemachines $computerarray 
#
#  Computer  CommandState  OutputOrErrors
#  --------  ------------  --------------
#  Host1     Sent		    
#  H2        Failed        Failed to connect...
#  H3        Pending
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
	$ShutdownCommand = { shutdown /s /m $args[0] /t 5 /c "Down for maintenance" } 
}
Process 
{
	$Computers = @()
	if (($ComputerArrayOrFile -eq $null) -or ($ComputerArrayOrFile -eq ""))
	{
		write-host "Usage: shutdown-thesemachines (get-content hosts.txt)"
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
	$tablefields = @{ Property=('Computer','CommandState','OutputOrErrors') } 
	foreach ($Computer in $Computers)
	{
		$computertable += New-Object -TypeName PSObject -Property @{ 
                             Computer=$Computer
                             CommandState="NotStarted"
                             OutputOrErrors=""
                        } | Select-Object @tablefields
	}
	
	# TODO Start job to send shutdown command
	foreach ($computer in $computertable)
	{
		Start-Job -Name $("Reboot" + $computer.Computer) -ScriptBlock $ShutdownCommand -ArgumentList $computer.Computer -ErrorAction Inquire 
	}
	
	
	if ($AutoRefresh)
	{
		While ($true)
		{
			foreach ($computer in $computertable)
			{
				if ($computer.CommandState -ne "Completed")
				{
					$job = get-job $("Reboot" + $computer.Computer)
					$computer.CommandState = $job.State
					
					if ($job.State -eq "Completed")
					{
						$error.clear()
						$computer.OutputOrErrors = Receive-Job $job
						if ($error.count -gt 0)
						{
							$computer.OutputOrErrors += $error[0]
						}
						Remove-Job $job
					}
				}
			}
			$computertable | Select-Object @tablefields | ft -a
			write-host "Ctrl C to exit"
			sleep $RefreshInSeconds
		}
	}
	else
	{	
		# Loop until stopped by any key except enter
		Do
		{
			foreach ($computer in $computertable)
			{
				if ($computer.CommandState -ne "Completed")
				{
					$job = get-job $("Reboot" + $computer.Computer)
					$computer.CommandState = $job.State
					
					if ($job.State -eq "Completed")
					{
						$computer.OutputOrErrors = Receive-Job $job
						Remove-Job $job
					}
				}
			}
			$computertable | Select-Object @tablefields | ft -a
		} 
		While ((Read-Host "Press enter to continue. Ctrl C or any text will exit.") -eq "")
	}
}
End 
{ 
	# Resetting ErrorActionPref 
	$ErrorActionPreference = $TempErrAct 
}

