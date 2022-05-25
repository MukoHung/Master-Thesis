$LinkNames = Import-Csv "c:\IT\LinkImport.csv"

Foreach ($Link in $LinkNames) {
    

    #give normal read access to every folder.
    #CMD.exe /C "icacls ""$($Link.LinkTargetSharePath)"" /grant ""$($Link.GroupToAccess):(OI)(CI)(RX)"" /C"

    #check to see if there are any subfolders
    $FolderNumber = Get-ChildItem -Path $Link.LinkTargetSharePath -Directory -Recurse

    #if there are no subfolders...
    If ($FolderNumber -eq $null) {
        Write-Output "Folder $($Link.LinkTargetSharePath) is Empty!"
    
    
        $acl = Get-Acl -Path $Link.LinkTargetSharePath
        $acl.Access | ForEach-Object { 
            #Check if the group is a dfs group
            $GroupName = $_.identityReference.value
            #$GroupName
            If ($GroupName -like "DAL\DFS*") {

              CMD.exe /C "icacls ""$($Link.LinkTargetSharePath)"" /grant ""$($GroupName):(OI)(CI)(M)"" /C"
        
            } 
        }
    }
} 