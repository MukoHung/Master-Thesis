#########################################################################
#                                                                       #
#    Script to set or clear read-only flag of an NTFS volume.           #
#                                                                       #
#    Usage: .\set-ntfs-ro.ps1 set   "MY DISK LABEL"                     #
#           .\set-ntfs-ro.ps1 clear "MY DISK LABEL"                     #
#                                                                       #
#    Author: Muhammed Demirbas, mmdemirbas at gmail dot com             #
#    Date  : 2013-03-23                                                 #
#                                                                       #
#########################################################################

param($setOrClear, $diskLabel)

if( [string]::IsNullOrWhiteSpace($setOrClear) )
{
    $ScriptName = $MyInvocation.MyCommand.Name
    "usage: .\$ScriptName set   ""MY DISK LABEL"""
    "       .\$ScriptName clear ""MY DISK LABEL"""
    return
}

if( $setOrClear -ne "set" -and $setOrClear -ne "clear" )
{
    throw 'Valid actions are "set" and "clear"!'
}

if( [string]::IsNullOrWhiteSpace($diskLabel) )
{
    throw "Please specify a non-blank disk label!"
}

# Path of the temporary file to use as diskpart script
$scriptFile = "$env:TMP\set-ntfs-ro-script.tmp"

# Save "list volume" command to a temp-file
"list volume" | Out-File -Encoding ascii $scriptFile

# Execute diskpart providing the script, and select the involved line
$matches = diskpart /s $scriptFile | Select-String $diskLabel
if( $matches.Length -eq 0 )
{
    throw "No match for the label: $diskLabel"
}
elseif ( $matches.Length -ge 2 )
{
    throw "More than one match for the label: $diskLabel"
}

# Obtain volume number
$words = $matches.Line.Trim().Split(" ")
if( !$words -or $words.Length -le 1 )
{
    throw "Volume number couldn't be obtained for the volume:`n$line"
}
$volumeNum = $words.Get(1)

# Save the command to modify read-only flag to a temp-file
"select volume $volumeNum
att vol $setOrClear readonly
detail vol" | Out-File -Encoding ascii $scriptFile

# Execute the command, and print details
diskpart /s $scriptFile

# Clean the waste
del $scriptFile
