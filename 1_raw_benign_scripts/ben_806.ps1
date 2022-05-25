$Servers = @("SERVER01","SERVER02","SERVER03")

$FolderPaths = $Servers | foreach {
    Get-ChildItem "\\$_\DFSShare$"
} | Sort Path

$FolderPaths | Export-Csv "FolderPaths-$(Get-Date -format yyyy-MM-dd).csv" -NoTypeInformation

$TestPaths = (($FolderPaths).FullName | Sort-Object).Trimend('\')
$DFSPaths = ((Import-CSV "DFS-$(Get-Date -format yyyy-MM-dd).csv").TargetPath | Where-Object {($_ -ilike "*SERVER*") | Sort-Object).Trimend('\')

$TestPaths | Where-Object {$DFSPaths -notcontains $_}