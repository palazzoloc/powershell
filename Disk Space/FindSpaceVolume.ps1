$CimSession = "."            

ForEach($item in Get-SmbShare -CimSession $CimSession | Where Volume) {            

    $volume = Get-Volume -CimSession $CimSession -Id $item.Volume            

    [PSCustomObject] @{            
        Share     = $item.Name            
        Path      = $item.Path            
        Size      = $volume.Size            
        Remaining = $volume.SizeRemaining             
    }            
}