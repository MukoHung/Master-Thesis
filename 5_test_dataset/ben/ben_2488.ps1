$Patches = Get-ChildItem -Path '.\*'  -Include *.msi
# $Patchdir | Format-List Name
foreach($Patch in $Patches){
    Write-Host $Patch.Name is installed
}
