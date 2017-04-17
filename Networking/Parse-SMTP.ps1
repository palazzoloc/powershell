############# Parse-W3C.ps1 ###############
# USAGE                                   #
# .\Parse-SMTP.ps1 -smtp "contenttosearchfor" -log "C:\Windows\System32\Logfiles\ex*.log"
#
# Found at http://scriptolog.blogspot.com/2007/08/smtp-log-parsing.html
# Updated by Chris Palazzolo
###########################################

param(
    [string]$smtpAddress = $(throw "Please specify email address"),
    [string]$log = $(throw "Please specify log file path, accepts wildcard")
)

#cls
$smtpAddress = "TO:<$smtpAddress>";

 

# the user may have more than one server associated, get list of all mail servers ips
$query="SELECT DISTINCT c-ip FROM $log WHERE cs-uri-query LIKE '%$smtpAddress%'";

$ips = logparser -i:W3C -q:ON $query;

if($ips.length -eq 0){
    write-host "Address not found.`n" -b black -f red;
    return;
}

 

# foreach ip returned emit the session

$ips | foreach {

    $query = "SELECT date,time,c-ip,cs-method,cs-uri-query FROM $log WHERE c-ip = '$_'";
    write-host "[QUERY] $query" -b black -f green;

    $lp=logparser -i:W3C -q:ON $query;


    # set start anchors where line matches "220+" (session starts)
    $session=@();    
    for($i=0;$i -le $lp.length;$i++){if($lp[$i] -match "-\s+220\+"){$session+=$i}}
    $session+=$lp.length;

    if($session.length -eq 0){
        write-host "`nNo sessions found for <$_>`n" -b black -f red;
        return;
    }

    $key = read-host "Found $($session.length) sessions for <$_>`n.Display All Sessions [A], User Sessions [U]?";
    write-host;

    for($i=0;$i -lt $session.length-1;$i++){
        # slice array
        $tmpArr = $lp[$session[$i]..$($session[$i+1]-1)];


        # regex to match any of 421,450,451,452,500,501,
        # 502,503,504,550,551,552,553,554 smtp error codes
        $regex =  "(-\s+)?(421|45[0-2]|5(0|5)[0-4])\+";


        # generic code to colorize SMTP errors
        [scriptblock]$paintRow = {
            $tmpArr | % {
                $email = [regex]::match($_,$smtpAddress).success;
                $err = [regex]::match($_,$regex).success;
                if($email){
                    if($err){write-host $_ -f red -b black}
                    else{write-host $_ -f yellow -b black}
                } 
                elseif($err){write-host $_ -f red -b black}                
                else{$_}
            }
        }

        if($tmpArr -match $smtpAddress -and $key -eq "u"){
            & $paintRow;
            if($i -eq 0){read-host "`nPress <ENTER> key to continue"} else{write-host}
        }            
        elseif($key -eq "a"){
            & $paintRow;
            if($i -lt $session.length-2){read-host "`nPress <ENTER> key to continue"} else{write-host}
        }
    }
}