function ConvertFrom-EventLogRecord
{
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [System.Diagnostics.Eventing.Reader.EventLogRecord[]]
        $InputEvent,

        [Parameter(Mandatory=$true,Position=1)]
        [ValidateNotNullOrEmpty()]
        [string[]]
        $Property
    )

    begin {
        [string[]]$xPathSelectorStrings = $Property |ForEach-Object {
            if($_ -like '*/*') {
                $_
            }
            else {
                'Event/EventData/Data[@Name="{0}"]' -f $_
            }
        }

        $propertySelector = [System.Diagnostics.Eventing.Reader.EventLogPropertySelector]::new($xPathSelectorStrings)
    }

    process {
        foreach($event in $InputEvent){
            $propertyValues = $event.GetPropertyValues($propertySelector)
            $properties = [ordered]@{}
            for($i = 0; $i -lt $propertyValues.Count; $i++){
                $properties[$Property[$i]-replace'^(?:.*\/)?([^\/]+)$','$1'] = $propertyValues[$i]
            }

            [pscustomobject]$properties
        }
    }
}