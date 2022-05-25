<#
.Synopsis
   This function will convert a Saba CSV for University Campus
.DESCRIPTION
   This function will import a CSV, modify the values, and export it to a new CSV.
   We rename the following headers:
        Person EMPID to EMPID
        Completed Courses (Transcript) Ended/Completed On Date to Completed On Date
        Course Course ID to Course ID
.EXAMPLE
   C:\> Convert-SabaToCampus -InFile C:\users\user\desktop\infile.csv -OutFile C:\users\user\desktop\outfile.csv
#>

    [CmdletBinding(DefaultParameterSetName='Parameter Set 1', 
                  SupportsShouldProcess=$true, 
                  PositionalBinding=$false,
                  HelpUri = 'http://www.microsoft.com/',
                  ConfirmImpact='Medium')]
    [Alias()]
    [OutputType()]
    Param
    (
        # Param1 help description
        [Parameter(Mandatory=$false, 
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=0)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()]
        $InFile = "C:\Users\readde\Desktop\TitleIX_test_fileIn.csv",

        # Param1 help description
        [Parameter(Mandatory=$false, 
                   ValueFromPipelineByPropertyName=$true, 
                   ValueFromRemainingArguments=$false, 
                   Position=1)]
        [ValidateNotNull()]
        [ValidateNotNullOrEmpty()] 
        $OutFile = "C:\Users\readde\Desktop\TitleIXFileOut.csv"

    )

    Begin
    {
        $ReturnObject = @()

        $DataIn = Import-Csv $InFile
    }
    Process
    {
        foreach ($d in $DataIn)
        {
            if ($pscmdlet.ShouldProcess("Target", "Operation"))
            {
                $props = @{
                    EMPID = $d.'Person EMPLID'
                    'Completed On Date' = [DateTime]::Parse($d.'Completed Courses (Transcript) Ended/Completed On Date').ToString('MM/dd/yyyy') 
                    'Course ID' = $d.'Course Course ID'
                }

                $tempObj = New-Object -TypeName PSCustomObject -Property $props
                $ReturnObject += $tempObj
            }
        }
    }
    End
    {
        $returnobject | Export-Csv -Path $OutFile -Force -NoTypeInformation
    }