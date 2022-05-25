
<#
================
PATCHCLEAN.PS1
=================
Version 1.0 Patch Folder Cleaner by Greg Linares (@Laughing_Mantis)

This Tool will go through the patch folders created by PatchExtract.PS1 and look for files created older 
than 30 days prior to the current date and move these to a sub folder named "OLD" in the patch folders.

This will help identify higher priority binaries that were likely updated in the current patch cycle window.

=======    
USAGE
=======
Powershell -ExecutionPolicy Bypass -File PatchClean.ps1 -Path C:\Patches\MS16-121\x86\

This would go through the x86 folder and create a subfolder named C:\Patches\MS16-121\x86\OLD\ and place
older files and their folders in that directory.

Files remaining in C:\Patches\MS16-121\x86\ should be considered likely targets for containing patched binaries

Empty folders are automatically cleaned and removed at the end of processing.

-PATH <STRING:FolderPath> [REQUIRED] [NO DEFAULT]
    Specified the folder that the script will parse and look for older files


================
VERSION HISTORY
================

Oct 20, 2016 - Version 1 - Initial Release


==========
LICENSING
==========
This script is provided free as beer.  It probably has some bugs and coding issues, however if you like it or find it 
useful please give me a shout out on twitter @Laughing_Mantis.  Feedback is encouraged and I will be likely releasing 
new scripts and tools and training in the future if it is welcome.


-GLin

#>

Param
(

    [Parameter(ValueFromPipelineByPropertyName = $true)]
    [ValidateNotNullOrEmpty()]
    [string]$PATH = ""
)


Clear-Host

if ($PATH -eq "")
{
    Throw ("Error: No PATH specified.  Specify a valid folder containing extracted patch files required. Generated by PatchExtract.ps1 ")
   
}

if (!(Test-Path $PATH))
{
    Throw ("Error: Invalid PATH specified '$PATH' does not exist.")
}

$OldDir = Join-Path -path $PATH -ChildPath "OLD"

if (!(Test-Path $OldDir -pathType Container))
{
    New-Item $OldDir -Force -ItemType Directory
    Write-Host "Making $OldDir Folder" -ForegroundColor Green
}

$FolderCount = 0
$FileCount = 0
$OldFiles = Get-ChildItem -Path $PATH -Recurse -File -Force -ErrorAction SilentlyContinue | Where{$_.LastWriteTime -lt (Get-Date).AddDays(-30)}


foreach ($OldFile in $OldFiles)
{
    try
    {
        $FileCount++
        $fileDir = (Get-Item($OldFile).DirectoryName)
        $folderName = (Get-Item $fileDir ).Basename
        $MoveDir = JOIN-Path -path $OldDir -ChildPath $folderName
        if (!(Test-Path $movedir))
        {
            Write-Host "Creating $folderName to $OldDir" -ForegroundColor Green
            New-Item $MoveDir -Force -ItemType Directory
            $FolderCount++
        }
        Move-Item $OldFile.fullname $MoveDir -Force

    }
    catch
    {
        Write-Host ("Error Processing " + $OldFile.fullname) -ForegroundColor Red
        Write-Host $_.Exception.Message
        Write-Host $_.Exception.ItemName
    }
}

#Clean Up Empty Folders

$EmptyFolders = Get-ChildItem -Path $PATH  -Recurse| Where-Object {$_.PSIsContainer -eq $True} | Where-Object {$_.GetFiles().Count -eq 0 -and $_.GetDirectories().Count -eq 0 } | Select-Object FullName


foreach ($EmptyFolder in $EmptyFolders)
{
    try
    {
        Write-Host ("Removing Empty Folder: " + $EmptyFolder.FullName) -ForegroundColor Yellow
        Remove-Item -Path $EmptyFolder.FullName -Force
    }
    catch
    {
        Write-Host ("Error Removing: " + $EmptyFolder.Fullname) -ForegroundColor Red
    }
}

Write-Host "=========================================================="

Write-Host "High-Priority Folders within $PATH :"

$NewFolders = Get-ChildItem -Path $PATH -Directory
$HighCount = 0

foreach ($folderName in $NewFolders)
{
    if (!($folderName -like "OLD"))
    {
        Write-Host $folderName
        $HighCount++
    }

}

Write-Host "=========================================================="

Write-Host ("Low Priority Folders: " + $FolderCount)
Write-Host ("Low Priority Files: " + $FileCount)
Write-Host ("High Priority Folders: " + $HighCount)