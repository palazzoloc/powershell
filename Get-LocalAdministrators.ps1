#Requires -Version 2.0

# -----------------------------------------------------------------------------
# Script: get-wmiadmin.ps1
# Version: 1.0
# Author: Jeffery Hicks
#    http://jdhitsolutions.com/blog
#    http://twitter.com/JeffHicks
#    http://www.ScriptingGeek.com
# Date: 7/1/2011
# Keywords: WMI
# Comments: A few functions to work with local administrators group using WMI
#
# "Those who forget to script are doomed to repeat their work."
#
#  ****************************************************************
#  * DO NOT USE IN A PRODUCTION ENVIRONMENT UNTIL YOU HAVE TESTED *
#  * THOROUGHLY IN A LAB ENVIRONMENT. USE AT YOUR OWN RISK.  IF   *
#  * YOU DO NOT UNDERSTAND WHAT THIS SCRIPT DOES OR HOW IT WORKS, *
#  * DO NOT USE IT OUTSIDE OF A SECURE, TEST SETTING.             *
#  ****************************************************************
# -----------------------------------------------------------------------------

Function Get-LocalAdministrators {

<#
.SYNOPSIS
Get members of the local administrators group
.DESCRIPTION
This function uses WMI to enumerate members of the local administrators group.
.PARAMETER Computername
The name of the computer to query. The default is the localhost.
.PARAMETER AsJob
Run the command as a background job. Remote computers must have PowerShell remoting enabled.
.EXAMPLE
PS C:\> Get-LocalAdministrators Client2

Name         : Administrator
Fullname     :
Caption      : CLIENT2\Administrator
Description  : Built-in account for administering the computer/domain
Domain       : CLIENT2
SID          : S-1-5-21-4228342518-2946215861-1035086974-500
LocalAccount : True
Disabled     : True
Computer     : CLIENT2

Name         : LocalAdmin
Fullname     :
Caption      : CLIENT2\LocalAdmin
Description  :
Domain       : CLIENT2
SID          : S-1-5-21-4228342518-2946215861-1035086974-1000
LocalAccount : True
Disabled     : False
Computer     : CLIENT2

Get members on Client2
.EXAMPLE
PS C:\> get-content computers.txt | get-LocalAdministrators -asjob
Creates a background job to query the administrators group on all computers in the text file.
.NOTES
NAME        :  Get-LocalAdministrators
VERSION     :  1.0   
LAST UPDATED:  7/1/2011
AUTHOR      :  Jeffery Hicks
.LINK
Get-WmiObject 
Invoke-Command 
.INPUTS
Strings
.OUTPUTS
Custom object
#>

[cmdletbinding()]

Param(
[Parameter(Position=0,ValueFromPipeline=$True,ValueFromPipelineByPropertyName=$True)]
[ValidateNotNullorEmpty()]
[string[]]$Computername=$env:computername,
[switch]$AsJob)

Begin {

    Set-StrictMode -Version latest
    Write-Verbose "Starting $($myinvocation.mycommand)"
    
    #define an new array for computernames if this is run as a job
    $computers=@()
}

Process {
    foreach ($computer in $computername) {
     $computers+=$Computer
     $sb={Param([string]$computer=$env:computername)
        Try {
            Write-Verbose "Querying $computer"
            $AdminsGroup=Get-WmiObject -Class Win32_Group -computername $Computer -Filter "SID='S-1-5-32-544' AND LocalAccount='True'" -errorAction "Stop" 
            Write-Verbose "Getting members from $($AdminsGroup.Caption)" 
            
            $AdminsGroup.GetRelated() | Where {$_.__CLASS -match "Win32_UserAccount|Win32_Group"} | 
            Select Name,Fullname,Caption,Description,Domain,SID,LocalAccount,Disabled,
            @{Name="Computer";Expression={$Computer.ToUpper()}}
        }
        Catch {
            Write-Warning "Failed to get administrators group from $computer"
            Write-Error $_
         }
      } #end scriptblock
      if (!$AsJob) {
        Invoke-Command -ScriptBlock $sb -ArgumentList $computer
      }
     } #foreach computer
} #process 

 End {
    #create a job is specified
    if ($AsJob) {
     Write-Verbose "Creating remote job"
     #create a single job targeted against all the computers. This will execute on each
     #computer remotely
     Invoke-Command -ScriptBlock $sb -ComputerName $computers -asJob
    }

 
    Write-Verbose "Ending $($myinvocation.mycommand)"
}
} #end function

#Optional aliases
#Set-Alias -Name gla -Value Get-LocalAdministrators
#Set-Alias -Name tla -Value Test-IsLocalAdministrator
