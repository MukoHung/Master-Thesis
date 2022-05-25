########################## Add Chia Nodes ##########################
# This script adds a list of Chia nodes to the currently installed #
# Chia client on your Windows 10 system.                           #
#                                                                  #
# See more info on Chia at https://chia.net.                       #
#                                                                  #
# You can download the latest Windows version of Chia from         #
# https://github.com/Chia-Network/chia-blockchain/releases.        #
#                                                                  #
# You are using this script at your own risk. I am unable to       #
# guarantee if any nodes have become malicious or not. If you know #
# of a way to check for this for each node, please let me know!    #
####################################################################

#Add your node/s to the array below.
$nodes = @(
    'node.chia.net:8444',
    'node-or.chia.net:8444',
    'node-eu.chia.net:8444',
    'node-apse.chia.net:8444',
    'node-apne.chia.net:8444',
    'introducer-va.chia.net:8444',
    'introducer-or.chia.net:8444',
    'introducer-eu.chia.net:8444',
    'introducer-apse.chia.net:8444',
    'introducer-apne.chia.net:8444'
)

#Get page content from below web page, which has Chia nodes listed.
$WebResponse = Invoke-WebRequest -Uri "https://chia.keva.app" -UseBasicParsing

$pageContent = $WebResponse.Content

$ipRegex = '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'

# Grab all the IP addresses from webpage content, then add them to existing nodes array.
# It is assumed that IP addresses listed on this page are Chia nodes.
$ip = $pageContent | Select-String -Pattern $ipRegex -AllMatches | % { $_.Matches } | % {($_.value + ':8444')}
$nodes += $ip

# Your Windows user directory.
$userdir = 'C:\Users\robattfield'

#Set the path to where the 'chia.exe' daemon executable is located.
Set-Location -Path ($userdir + '\AppData\Local\chia-blockchain\app-*\resources\app.asar.unpacked\daemon\')

# Iterate over the nodes array, adding each one to the Chia client with a 1 second pause between each.
# The time it takes for each node depends on their connection quality and if they are accepting requests.
$nodes | ForEach-Object {$host.ui.RawUI.WindowTitle = "Adding Chia Node $($PSItem)"; .\chia.exe show -a $PSItem}

cmd /c 'pause'