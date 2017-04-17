Function Get-NtfsRights($name,$path,$comp) 
{
	$path = [regex]::Escape($path) 
	$share = "\\$comp\$name" 
	$path = $path -replace "\\ "," " 
	$path 
	$wmi = gwmi Win32_LogicalFileSecuritySetting -filter "path='$path'" -ComputerName $comp 
	$wmi.GetSecurityDescriptor().Descriptor.DACL | where {$_.AccessMask -as [Security.AccessControl.FileSystemRights]} |select ` 
	@{name="Principal";Expression={"{0}\{1}" -f $_.Trustee.Domain,$_.Trustee.name}}, 
	@{name="Rights";Expression={[Security.AccessControl.FileSystemRights] $_.AccessMask }}, 
	@{name="AceFlags";Expression={[Security.AccessControl.AceFlags] $_.AceFlags }}, 
	@{name="AceType";Expression={[Security.AccessControl.AceType] $_.AceType }}, 
	@{name="ShareName";Expression={$share}} 
} 

$computer = "fileserver.domain.local" 

if ($shares = Get-WmiObject Win32_Share -ComputerName $computer | Where {$_.Path}) 
{
	$shares | Foreach { Write-Progress -Status "Get share information on $($_.__Server)" $_.Name 
		Get-NtfsRights $_.Name $_.Path $_.__Server} 
} 
else {"Failed to get share information from {0}." -f $($_.ToUpper())} 
