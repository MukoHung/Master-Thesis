<#
.SYNOPSIS
    Digitally signs a PowerShell script.
.DESCRIPTION
    Digitally signs a PowerShell script. Uses the first CodeSigning certificate found in your 
    certificate store.
.PARAMETER sFile
    Name of Script to be Signed
.EXAMPLE
    C:\etc\scripts>.\sign-psfile -ScriptFile C:\etc\scripts\test-script.ps1
    Another example of how to use this cmdlet
.NOTES
    ===========================================================================
    Created with: 	Visual Studio Code
    Created on:   	05.02.2014
    Created by:   	John Kavanagh
    Organization: 	Kavanaghtech
    Filename:     	sign-psfile.ps1
    ===========================================================================
    06.08.2017 JJK: Done: Add File Open Dialog Box to allow operator to select file to
                    sign
    06.08.2017 JJK: File gets signed but Status shows as UnknownError
#>
[CmdletBinding(SupportsShouldProcess=$true,ConfirmImpact='Medium')]
Param( 
    [Parameter(ValueFromPipeline=$true, Mandatory=$false)]
    [Alias("ScriptFile")]
    [String]$sFile 
)
# Show an Open File Dialog and return the file selected by the user.
Function get-ScriptFile {
Param(
    $initialDirectory
)
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null
    $OpenFileDialog = New-Object System.Windows.Forms.OpenFileDialog
    $OpenFileDialog.InitialDirectory = $initialDirectory
    $OpenFileDialog.Filter = "PS1 (*.ps1) | *.ps1"
    $OpenFileDialog.ShowDialog() | out-null
    $OpenFileDialog.FileName
}
$sFile = get-ScriptFile -initialDirectory "c:\"
if ($sFile) { "You selected {0} to be digitally signed" -f $sFile}
else { "You did not select a file." }
# If file entered on commandline exists digitally sign    
if (test-path $sFile){
    "Signing $sFile"
    # Select the Certificate designate for CodeSigning
    if ($cert = @(Get-ChildItem -Path cert: -Recurse -CodeSigningCert )[0]){
        Try {
            # Sign file 
            Set-AuthenticodeSignature -FilePath $sFile -Certificate $cert -Verbose -ErrorAction Stop
        }
        Catch {
            "Unable to sign {0}" -f $sFile
        }
    }
    Else {
        "No Valid Certificate found"
    }
}
Else { "Unable to find $($sFile)" }