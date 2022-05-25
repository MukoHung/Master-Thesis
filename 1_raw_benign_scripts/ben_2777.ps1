# Add windows Explorer Right-Click menu to paste copied item as Junction or SymbolicLink with PowerShell
# Locate file on C:\CMD\
 param (
    [Parameter(Mandatory=$true)][string]$location
 )

Set-Location $location
$files = Get-Clipboard -Format FileDropList
$count = $files.count;
if($count -eq 0)
{
    echo "No file(s) in clipboard"
    pause
    exit
}
echo "Making Junction/Link of $count files"
foreach ($file in $files)
{
    if( (Test-Path $file.Name) -eq $true ){
        echo "$($file.Name) Exists"
    }else{
        if($file.Attributes -eq 'Directory')
        {
            #echo "Junction: $($file.Name) -> $file"
            New-Item -ItemType Junction -Name $file.name -Target $file
        } else
        {
            #echo "SymLink : $($file.Name) -> $file"
            New-Item -ItemType SymbolicLink -Name $file.name -Target $file
        }
            
    }
    
}
pause