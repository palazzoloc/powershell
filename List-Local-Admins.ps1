# List local group members on the local or a remote computer

$computerName = Read-Host 'Enter computer name or press <Enter> for localhost'
$localgroupName = Read-Host "Enter local group name"
if ($computerName -eq "") {$computerName = "$env:computername"}

if([ADSI]::Exists("WinNT://$computerName/$localGroupName,group")) {

	$group = [ADSI]("WinNT://$computerName/$localGroupName,group")

	$members = @()
	$Group.Members() |
	% {
		$AdsPath = $_.GetType().InvokeMember("Adspath", 'GetProperty', $null, $_, $null)
		# Domain members will have an ADSPath like WinNT://DomainName/UserName.
        # Local accounts will have a value like WinNT://DomainName/ComputerName/UserName.
		$a = $AdsPath.split('/',[StringSplitOptions]::RemoveEmptyEntries)
		$name = $a[-1]
		$domain = $a[-2]
		$class = $_.GetType().InvokeMember("Class", 'GetProperty', $null, $_, $null)

		$member = New-Object PSObject
		$member | Add-Member -MemberType NoteProperty -Name "Name" -Value $name
		$member | Add-Member -MemberType NoteProperty -Name "Domain" -Value $domain
		$member | Add-Member -MemberType NoteProperty -Name "Class" -Value $class

		$members += $member
	}
	if ($members.count -eq 0) {
		Write-Host "Group '$computerName\$localGroupName' is empty."
	}
	else {
		Write-Host "Group '$computerName\$localGroupName' contains these members:"
		$members | Format-Table Name,Domain,Class -autosize
	}
}
else {
	Write-Warning "Local group '$localGroupName' doesn't exist on computer '$computerName'"
}