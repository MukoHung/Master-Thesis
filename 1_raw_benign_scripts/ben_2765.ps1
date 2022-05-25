<#
This script adds a packet capture to all virtual machines within a given Resource Group that match a tag value

To run, invoke the script as follows:
./packet-capture.ps1 start
./packet-capture.ps1 stop
./packet-capture.ps1 clean

The 'stop' command stops all packet captures for each virtual machine that are currently running
The 'clean' command deletes all packet captures that are in a stopped state

NOTE: Captures will end after the 1GB max size or the 5 hour limit.
#>

# Variables
$subscriptionName = ""
$rgName = ""
$region = ""
$storageAccountRG = ""
$storageAccountName = ""
$tagName = ""
$tagValue = ""

$action = $args[0]

if ($action -ne "start" -and $action -ne "stop" -and $action -ne "clean") {
    Write-Error "run this script with 'stop', 'start', or 'clean' as an argument"
    exit
}

Connect-AzAccount
Set-AzContext -Subscription $subscriptionName

Enable-AzContextAutosave # Enables context autosave if not already on

$subId = (get-azcontext).Subscription.Id

$storageaccountid = "/subscriptions/$subId/resourceGroups/$storageAccountRG/providers/Microsoft.Storage/storageAccounts/$storageAccountName"
$networkWatcher = Get-AzNetworkWatcher -Location $region
$packetCaptureDuration = 18000
$vms = Get-AzVM -ResourceGroupName $rgName | Where-Object { $_.Tags[$tagName] -eq $tagValue }
$packetCaptureTime = (get-date -Format FileDateTime)

foreach ($vm in $vms) {

    $packetCaptureName = $packetCaptureTime + "-" + $vm.Name

    if ($action -eq "start") {
        Write-Host "Creating packet capture for: " $vm.Name
        New-AzNetworkWatcherPacketCapture -NetworkWatcher $networkWatcher -TargetVirtualMachineId $vm.Id -PacketCaptureName $packetCaptureName -StorageAccountId $storageaccountid -TimeLimitInSeconds $packetCaptureDuration -AsJob
        Write-Host "Packet capture created: $packetCaptureName"
    }
    if ($action -eq "stop") {
        $captures = Get-AzNetworkWatcherPacketCapture -NetworkWatcher $networkWatcher
        foreach ($capture in $captures) {
            if ($capture.Target -eq $vm.Id -And $capture.PacketCaptureStatus -eq "Running") {
                Stop-AzNetworkWatcherPacketCapture -NetworkWatcher $networkWatcher -PacketCaptureName $capture.Name -AsJob
                Write-Host "Packet capture stopped:" $capture.Name
            }
        }
    }
    if ($action -eq "clean") {
        $captures = Get-AzNetworkWatcherPacketCapture -NetworkWatcher $networkWatcher
        foreach ($capture in $captures) {
            if ($capture.PacketCaptureStatus -eq "Stopped") {
                Remove-AzNetworkWatcherPacketCapture -NetworkWatcher $networkWatcher -PacketCaptureName $capture.Name -AsJob
                Write-Host "Packet capture deleted:" $capture.Name
            }
        }
    }
    
}