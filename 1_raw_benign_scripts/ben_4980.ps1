

$PROCESS = 'ethminer'
$PATH = "C:\Users\sysadmin\Downloads\ethermine.bat"
#Get-Process | Select-String $PROCESS


function Watch-Miner{

    param ([string]$proc, [string]$app)

    $proc_status = Get-Process | Select-String $proc

    if ($null -eq $proc_status) {
        #& $app
        start-process $app #TODO: try,catch
        return $false  #not running

    }
    return $true  #running
}


<#todo#>
#func get status
#func restart service
#func log to file, sqlite
#func email, text msg
#func underclock, undervolt GPUs if rebbot happened
#make into windows service


while ($true){
    echo "running watchdog func..."
    $miner_status = Watch-Miner $PROCESS $PATH
    echo "status=$miner_status"
    Start-Sleep -Seconds 60
}


#https://docs.microsoft.com/en-us/powershell/scripting/overview?view=powershell-7.1
#https://devblogs.microsoft.com/powershell/new-object-psobject-property-hashtable/
#https://devblogs.microsoft.com/scripting/learn-how-to-use-net-framework-commands-inside-windows-powershell/
#https://docs.microsoft.com/en-us/dotnet/standard/io/
#https://docs.microsoft.com/en-us/dotnet/api/system.io.file?view=net-5.0

#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.management/start-process?view=powershell-7.1
#https://docs.microsoft.com/en-us/powershell/module/threadjob/start-threadjob?view=powershell-7.1
#https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/start-job?view=powershell-7.1
#https://devblogs.microsoft.com/scripting/parallel-processing-with-jobs-in-powershell/
#https://devblogs.microsoft.com/scripting/beginning-use-of-powershell-runspaces-part-1/


<#
$is_dir = [io.directory]::Exists("<path>")
$is_file = [io.file]::Exists("<path>")

if (!$is_dir){
    #do this
}

if (!$is_dir){
    #do that
}

$fd = [io.file]::OpenText("<path>")
while ($null -ne ($line = $fd.readline())) {
    echo $line
}
#>



