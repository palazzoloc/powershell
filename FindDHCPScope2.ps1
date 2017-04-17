$D = get-date -uformat “%d.%m.%Y”
$path1 = "E:\TOOLS\All_DHCP_Scope_Options_$D.csv"
$Hostlist = "E:\TOOLS\DHCPServers.txt"
write-host $Hostlist
foreach ($host in $HostList) 
	{
	$Scopes = Get-DhcpServerv4Scope -Computername $host 
		foreach ($Scope in $Scopes) 
			{
			Get-DhcpServerv4OptionValue -ScopeId $Scope.ScopeId.IPAddressToString -All | Sort-Object -Descending -Property OptionId | select @{Expression={$Scope.ScopeId.IPAddressToString};Label=”SCOPE”},OptionId,Name,Type,UserClass,PolicyName,@{Expression={$_.Value};Label=”Value”} | export-csv -Path $path1 -append 
			}
	}