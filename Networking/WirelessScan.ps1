<#
.SYNOPSIS
   <A brief description of the script>
.DESCRIPTION
   <A detailed description of the script>
.PARAMETER <paramName>
   <Description of script parameter>
.EXAMPLE
   <An example of using the script>
#>

# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=
#          Name: wlanscan
#        Author: Kris Cieslak (defaultset.blogspot.com)
#          Date: 2010-04-03
#   Description: Simple script that uses netsh to show wireless networks.
#
#    Parameters: wireless interface name (optional,but recommended if you have
#                more than one card)
#        Result: $ActiveNetworks
# Usage example: wlanscan WiFi
#
# -=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-=-=-=-=-=-=-
PARAM ($ifname = "")

# Windows Vista/2008/7
if  ((gwmi win32_operatingsystem).Version.Split(".")[0] -lt 6) {
	throw "This script works on Windows Vista or higher."
}
if ((gsv "wlansvc").Status -ne "Running" ) {
	throw "WLAN AutoConfig service must be running."
}
$GLOBAL:ActiveNetworks = @();
$CurrentIfName = "";	
$n = -1;
$iftest = $false;

netsh wlan show network mode=bssid | % {
	if ( $_ -match "Interface") {
		$CurrentIfName = [regex]::match($_.Replace("Interface name : ","")
			                            ,"\w{1,}").ToString();
	    if (($CurrentIfName.ToLower() -eq $ifname.ToLower()) -or ($ifname.length -eq 0)) {
		    $iftest=$true;
		} else { $iftest=$false }
	}	 
	
	$buf = [regex]::replace($_,"[ ]","");
	if ([regex]::IsMatch($buf,"^SSID\d{1,}(.)*") -and $iftest) {
	   	$item = "" | Select-Object SSID,NetType,Auth,Encryption,BSSID,Signal,Radiotype,Channel;
		$n+=1;
       	$item.SSID = [regex]::Replace($buf,"^SSID\d{1,}:","");
		$GLOBAL:ActiveNetworks+=$item;
	}
  	if ([regex]::IsMatch($buf,"Networktype") -and $iftest) {
	   	$GLOBAL:ActiveNetworks[$n].NetType=$buf.Replace("Networktype:","");
	}
	if ([regex]::IsMatch($buf,"Authentication") -and $iftest) {
	   	$GLOBAL:ActiveNetworks[$n].Auth=$buf.Replace("Authentication:","");
	}
	if ([regex]::IsMatch($buf,"Encryption") -and $iftest) {
	   	$GLOBAL:ActiveNetworks[$n].Encryption=$buf.Replace("Encryption:","");
	 	}
        if ([regex]::IsMatch($buf,"BSSID1") -and $iftest) {
	   	$GLOBAL:ActiveNetworks[$n].BSSID=$buf.Replace("BSSID1:","");
	}
	if ([regex]::IsMatch($buf,"Signal") -and $iftest) {
	   	$GLOBAL:ActiveNetworks[$n].Signal=$buf.Replace("Signal:","");
	}
	if ([regex]::IsMatch($buf,"Radiotype") -and $iftest) {
	   	$GLOBAL:ActiveNetworks[$n].Radiotype=$buf.Replace("Radiotype:","");
	}
	if ([regex]::IsMatch($buf,"Channel") -and $iftest) {
	  	$GLOBAL:ActiveNetworks[$n].Channel=$buf.Replace("Channel:","");
	}
}
if ( ($CurrentIfName.ToLower() -eq $ifname.ToLower()) -or ($ifname.length -eq 0) ) {
	write-host -ForegroundColor Yellow "`nInterface: "$CurrentIfName;
	if (($GLOBAL:ActiveNetworks.length -gt 0)) {
   		$GLOBAL:ActiveNetworks | Sort-Object Signal -Descending | 
			ft @{Label = "BSSID"; Expression={$_.BSSID };width=18},
               @{Label = "Channel"; Expression={$_.Channel};width=8},
			   @{Label = "Signal"; Expression={$_.Signal};width=7},
			   @{Label = "Encryption"; Expression={$_.Encryption};width=11},
   			   @{Label = "Authentication"; Expression={$_.Auth};width=15},
			   SSID
	} else {
	   Write-host "`n No active networks found.`n";
	}
} else {
  Write-host -ForegroundColor Red "`n Could not find interface: "$ifname"`n";
}