function ConvertFrom-IISW3CLog {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, ValueFromPipelineByPropertyName)]
        [Alias('PSPath')]
        [string[]]
        $Path
    )

    process {

        foreach ($SinglePath in $Path) {

            $FieldNames = $null
            $Properties = @{}

            Get-Content -Path $SinglePath |
                ForEach-Object {
                    if ($_ -match '^#') {
                        #metadata
                        if ($_ -match '^#(?<k>[^:]+):\s*(?<v>.*)$') {
                            #key value pair
                            if ($Matches.k -eq 'Fields') {
                                $FieldNames  = @(-split $Matches.v)
                            }
                        }
                    } else {
                        $FieldValues = @(-split $_)
                        $Properties.Clear()
                        for ($Index = 0; $Index -lt $FieldValues.Length; $Index++) {
                            $Properties[$FieldNames[$Index]] = $FieldValues[$Index]
                        }
                        [pscustomobject]$Properties
                    }
                }

        }

    }
}