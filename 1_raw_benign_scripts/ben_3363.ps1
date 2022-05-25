$retries = 3 #$OctopusParameters['appPoolCheckRetries']
$delay = 1000 #$OctopusParameters['appPoolCheckDelay']
$counter = 1
do {
    try {
        #Script Here        
        Break
    } catch {
        Write-Error $_.Exception.InnerException.Message -ErrorAction Continue        
        Write-Host "Attemp $counter failed."
        Write-Host "Waiting for $delay milliseconds and retrying again..."
        Start-Sleep -Milliseconds $delay
        $counter++
    }
} while ($counter -le $retries)

if($counter -ge $retries) { 
    throw "Could not run script properly. `nTry to increase the number of retries ($retries) or delay between attempts ($delay milliseconds)." }
