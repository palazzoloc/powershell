# ==============================================================================================
# 
# Microsoft PowerShell Source File -- Created with SAPIEN Technologies PrimalScript 2011
# 
# NAME: 
# 
# AUTHOR: James Vierra , Designed Systems & Services
# DATE  : 12/18/2011
# 
# COMMENT: 
# 
# ==============================================================================================
function get-IPAddress {
    [CmdletBinding()]
    param (
        [string]$computer=$env:COMPUTERNAME
    )
    
    Get-WmiObject -Class Win32_NetworkAdapterConfiguration -ComputerName $computer -filter 'IPEnabled="True"' |
    ForEach-Object{
    
        $address = $_.IPAddress[1]            
    
        Write-Verbose "Test for ::"
        if ($_.IPAddress[1].Contains("::")){
            $blocks = $_.IPAddress[1] -split ":"
            $count = $blocks.Count
            $replace = 8 - $count + 1
            for ($i=0; $i -le $count-1; $i++){
                if ($blocks[$i] -eq ""){
                    $blocks[$i] = ("0000:" * $replace).TrimEnd(":")
                }
            }
            $address = $blocks -join ":"
        }            
    
        Write-Verbose "Check leading 0 in place"
        $blocks = $address -split ":"
        for ($i=0; $i -le $blocks.Count-1; $i++){
            if ($blocks[$i].length -ne 4){
                $blocks[$i] = $blocks[$i].Padleft(4,"0")
            }
        }
    
        $address = $blocks -join ":"            
      
        New-Object -TypeName PSObject -Property @{
                Description = $($_.Description)
                IPv4Address = $($_.IPAddress[0])
                IPv4Subnet = $($_.IPSubnet[0])
                IPv6Address = $address
                IPv6Subnet = $($_.IPSubnet[1])
                DeviceId =  $($_.Index)
            }
    }
}

get-IPAddress