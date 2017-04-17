<#  

.Synopsis
    Script to find a speicifc VMHost on all DHCP servers in the EXO Lab.

.Description
    This script will remotely find the Hostname of a VM
    This will search thru all the known Outlooklab VMhost and spit out the VM hostname
.Usage
    .\FindDHCPVMHost.ps1 -VMHost 10.126.180.0

.Notes
    - Script will query VM Hosts that we have access (we are in the admin group/Domain Joined).
            
    - $HostList of GetExoVmHost Funtion needs to be updated (add/remove) if there are any changes to the EXO VM hosts 

.Author
    cpalazzo


#>

Function GetVMHost()
{
    #array list of host
    $HostList = "SVM-TDS-VMHOST0",
                "SVM-TDS-VMHOST1",
                "SVM-TDS-VMHOST2",
                "SVM-TDS-VMHOST3",
                "SVM-TDS-VMHOST4",
                "SVM-TDS-VMHOST5",
                "SVM-TDS-VMHOST6",
                "SVM-EX-VMHOST1",
                "SVM-EX-VMHOST2",
                "SVM-EX-VMHOST3",
                "SVM-EX-VMHOST4",
                "SVM-EX-VMHOST5",
                "SVM-EX-VMHOST6",
                "SVM-EX-VMHOST7",
                "SVM-EX-VMHOST8",
                "SVM-EX-VMHOST9",
                "SVM-EX-VMHOST10",
                "SVM-INT-VMHOST1",
                "SVM-INT-VMHOST2",
                "SVM-INT-VMHOST3",
                "SVM-MAIN-VMHOST",
                "SVM-DEV-VMHOST",
				"SVM-LAB-VMHOST1",
				"SVM-LAB-VMHOST2"

    #initialize hostname to empty
    $hostname=" "
    
    foreach ($i in $HostList) 
    {
        Add-Content -Value "SCOPE,OPTIONID, NAME, TYPE, VALUE" -Path .\DHCP_Scope_Options.csv
		$Scopes = Get-DhcpServerv4Scope -Computername $i

		foreach ($Scope in $Scopes) 
		{
		$Options = Get-DhcpServerv4OptionValue -ComputerName $i -ScopeId $Scope.ScopeId.IPAddressToString -All | Sort-Object -Descending -Property OptionId
		for ($i = ($Options.Count -1); $i -gt 0; $i-- )
			{
			Add-Content -Value "$($Scope.ScopeId.IPAddressToString),$($Options[$i].OptionId),$($Options[$i].Name),$($Options[$i].Type),$($Options[$i].Value)" -Path .\DHCP_Scope_Options.csv
			}
		}
    }
    
    return($hostname)
}

#Write-Host "VMHOST: $vmhost -- DHCPScope: $Scope" -ForegroundColor Yellow
