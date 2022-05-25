<#
--------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- 
.SYNOPSIS 
    Merge source files to single ps1.file.
    This is the entry point of mergeToSinglePS.ps1

.DESCRIPTION
    Replace Import-Module to content of the module.
    "Import-Module specific_module.ps1" in the inFile will replace the contents of specific_module.ps1.
    path to specific_module.ps1 should be absolute path or relateve path from inFile.


.INPUTS
    None. You cannot pipe objects.

.OUTPUTS
    None. Return nothing.

.EXAMPLE
    convertTo-StandaloneScript.ps1 -inFile "/path/to/input.ps1" -outFile "/path/to/input.ps1"

--------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- 
#>

param(
    [parameter(mandatory=$true)][String]$inFile,
        # Specify input .ps1 script file.
    [parameter(mandatory=$true)][String]$outFile
        # Specify output .ps1 script file.
)

<#
--------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- 
    .SYNOPSIS 
        Merge source files to single ps1.file.
        This is the entry point of mergeToSinglePS.ps1

    .DESCRIPTION
        Replace Import-Module to content of the module.
        "Import-Module specific_module.ps1" in the inFile will replace the contents of specific_module.ps1.
        path to specific_module.ps1 should be absolute path or relateve path from inFile.

    .PARAMETER  InFile
        Specify input .ps1 script file.

    .PARAMETER  OutFile
        Specify output .ps1 script file.

]    .INPUTS
        None. You cannot pipe objects.

    .OUTPUTS
        None. Return nothing.

    .EXAMPLE
        convertTo-StandaloneScript -inFile "/path/to/input.ps1" -outFile "/path/to/input.ps1"
#>
function ConvertTo-StandaloneScript(){
    param(
            [parameter(mandatory=$true)][String]$inFile,
                # Specify input .ps1 script file.
            [parameter(mandatory=$true)][String]$outFile
                # Specify output .ps1 script file.
    )
    # show message
    Write-Host("Start to convert");
    Write-Host("inFile  "+$inFile);
    Write-Host("outFile "+$outFile);

    # set directory from inFile.
    Set-Location(Split-Path($inFile));
    Write-Host("Current Directiory "+(Get-Location));

    # read line from inFile
    # replace "Import-Module" with target module content
    foreach($line in Get-Content($inFile)){
        # "Import-Module" line
        if($line.trimU() -match "^Import-Module"){
            $modName=($line.replace("Import-Module","")).trim(); 
            Append-AllScriptLine -inFile $modName -outFile $outFile;
            Write-Host("replaced `"$line`"");
        # normal line
        }else{
            Add-Content -Path $outFile -Value $line;
        }        
    }

    # show message
    Write-Host("Finished");
}


<#
--------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- --------- 
    .SYNOPSIS 
        Append all lines in the file to the specified outfile

    .DESCRIPTION
        Read all lines from inFile
        Append all lines to outFile 

    .PARAMETER  InFile
        Specify input .ps1 script file.

    .PARAMETER  OutFile
        Specify output .ps1 script file.

    .INPUTS
        None. You cannot pipe objects.

    .OUTPUTS
        None. Return nothing.

    .EXAMPLE
        Append-AllScriptLine -inFile "/path/to/input.ps1" -outFile "/path/to/input.ps1"
#>
function Append-AllScriptLine(){
    param(
            [parameter(mandatory=$true)][String]$inFile,
                # Specify input .ps1 script file.
            [parameter(mandatory=$true)][String]$outFile
                # Specify output .ps1 script file.
    )
    foreach($line in Get-Content($inFile)){
        Add-Content -Path $outFile -Value $line
    }
}

# default action
if ($MyInvocation.InvocationName -ne ".") {
    convertTo-StandaloneScript -inFile "$inFile" -outFile "$outFile";
}
