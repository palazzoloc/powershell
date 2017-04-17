<#
.SYNOPSIS
   Pull Network Information fomr multiple servers in a List.
.DESCRIPTION
   
.PARAMETER <paramName>
   no arguments needed.
   must supply corect location of server_list.txt file
.EXAMPLE
   <An example of using the script>
#>

$servers = Get-Content 'E:\SCRIPTS\RemoveScomAgent.txt' 
ForEach ($server in $servers) {
	# Ping the machine to see if it's on the network

	$results = Get-WmiObject -ComputerName $server Win32_NetworkAdapterConfiguration | Where-Object { $_.IPAddress -ne $null } 
	$responds = $false 
	ForEach-Object {
		# If the machine responds break out of the result loop and indicate success
		if ($result.statuscode -eq 0) {
			$responds = $true
			break
		}
	}
	If ($responds) {

		# Gather info from the server because it responds
		Write-Output "$server responds"
	} else {

		# Let the user know we couldn't connect to the server
		Write-Output "$server does not respond"


	}
}