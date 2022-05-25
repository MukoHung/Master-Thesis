$target = "chrome"
$process = Get-Process | Where-Object {$_.ProcessName -eq $target}
while ($true)
{
    while (!($process))
    {
        $process = Get-Process | Where-Object {$_.ProcessName -eq $target}
        start-sleep -s 5
    }

    if ($process)
    {
        "Chrome is running"
        $process.WaitForExit()
        start-sleep -s 2
        $process = Get-Process | Where-Object {$_.ProcessName -eq $target}
        "Chrome is shutting down"
    }
}