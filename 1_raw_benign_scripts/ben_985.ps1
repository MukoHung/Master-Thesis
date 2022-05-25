$TARGET_MACHINE_NAME = "MyMachineName"

$DirectoryListToCreate = @(
"D:\TestFolder1\Subfolder1\TestNest1",
"D:\TestFolder2\Subfolder2\TestNest2\AnotherNestedFolder2",
"D:\TestFolder3\Subfolder3\"
)


#Set Ouput Messages Color
$ERROR_COLOR = 'Red'
$WARNING_COLOR = 'Yellow'
$SUCCESS_COLOR = 'Green'

Clear-Host
if($TARGET_MACHINE_NAME -eq $env:COMPUTERNAME)
{
    foreach($Directory in $DirectoryListToCreate)
    {
        if(-not(Test-Path $Directory))
        {
            New-Item -ItemType Directory -Force -Path $Directory
            Write-Host "Directory $Directory Created" -ForegroundColor $SUCCESS_COLOR
        }
        else
        {
            Write-Host "Skipped Directory $Directory because it already exists" -ForegroundColor $WARNING_COLOR
        }           
    }
}
else {   
   Write-Host "Failed. No Directories created. Please check and run on the target machine." -ForegroundColor $ERROR_COLOR
}