function Share-CrashDumps {
    "From https://devblogs.microsoft.com/scripting/how-to-use-powershell-to-create-shared-folders-in-windows-7/"

    $crashDumpsDir = "C:\CrashDumps"
    $shareDir = "CrashDumps"
    IF (!(TEST-PATH $crashDumpsDir)) {
                    NEW-ITEM $crashDumpsDir -type Directory
    }

    $Shares=[WMICLASS]"WIN32_Share"

    If (!(GET-WMIOBJECT Win32_Share -filter "name='$shareDir'")) {
        $Shares.Create($crashDumpsDir,$shareDir,0)
    }
}