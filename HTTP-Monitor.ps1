
$www = 'https://google.com'

$get = Invoke-WebRequest -Uri $www

Try {
    if ($get.StatusCode -eq 200)
    {
        Do 
        {
            $dt = Get-Date -Format G
            Write-Host "$www : $dt (SUCCEEDED)"
            Start-Sleep -s 5
            $start++
        } While($get.StatusCode -eq 200) 

    }
    else 
    {
        Write-Host "$www : $dt (FAILED)"
        #Start-Sleep -s 5
    }
}
Catch 
{
    "$_"
}
