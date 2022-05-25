# Ransomware Killer v0.1 by Thomas Patzke <thomas@patzke.org>
# Kill all parent processes of the command that tries to run "vssadmin Delete Shadows"
# IMPORTANT: This must run with Administrator privileges!
Register-WmiEvent -Query "select * from __instancecreationevent within 0.1 where targetinstance isa 'win32_process' and targetinstance.CommandLine like '%vssadmin%Delete%Shadows%'" -Action {
    # Kill all parent processes from detected vssadmin process
    $p = $EventArgs.NewEvent.TargetInstance
    while ($p) {
       $ppid = $p.ParentProcessID
        $pp = Get-WmiObject -Class Win32_Process -Filter "ProcessID=$ppid"
        Write-Host $p.ProcessID
        Stop-Process -Id $p.ProcessID
        $p = $pp
    }
    # Kill all processes that have ":bin" in their name (BitPaymer)
    Get-WmiObject -Class Win32_Process -Filter "CommandLine like '%:bin%'" | ForEach-Object {
        Write-Host $_.ProcessID
        Stop-Process -Id $_.ProcessID
    }
    [System.Windows.Forms.MessageBox]::Show("Your system was likely infected with a Ransomware. I've killed it for you, but further remediation actions are required","RansomwareKiller",0)
}