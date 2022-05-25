# Big thanks to the original creator of this script, IamLukeVice: https://www.reddit.com/user/IamLukeVice
#
# Copy all this content, paste in notepad and save as a ps1 file, example: Fix-Fornite-Replays.ps1
# Then, open the folder containing the script, right click it and choose: Run With Powershell
# If it doesnt run, follow this: https://superuser.com/questions/106360/how-to-enable-execution-of-powershell-scripts
#
# Script to delete duplicate replay files: https://gist.github.com/fredimachado/1a3d36f34e786a423328a347ff11215a
$LocalAppDataFolder = "$env:LOCALAPPDATA"
$FortniteReplaysFolder = $LocalAppDataFolder + "\FortniteGame\Saved\Demos"
$count = 0
Get-Childitem $FortniteReplaysFolder -Filter *.replay |
Foreach-Object {
    $bytes  = [System.IO.File]::ReadAllBytes($_.fullname)
    $offset = 0x10
    if($bytes[$offset] -ne 0x49){
        "Fixing: " + $_.Name
        $bytes[$offset]   = 0x49
        $bytes[$offset+1] = 0xfb
        $bytes[$offset+2] = 0x58
        [System.IO.File]::WriteAllBytes($_.DirectoryName + "\fixed-" + $_.Name, $bytes)
        $count++
    }
    else{ "Already correct version: " + $_.Name }
}
"Fixed " + $count + " Files."
"Press a key..."; $x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")