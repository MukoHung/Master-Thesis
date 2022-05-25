## Convert PowerShell Script to SSM Document JSON format

function Convert-PSScriptToSSM ($sourceScript, $targetScript, $description, $timeOut) {

    # Create the script new
    New-Item -ItemType File -Path $targetScript -Force

    # get the contents of the script
    $scriptLines = Get-Content -path $sourceScript
    $totalLines = $scriptLines.Count
    $lineCount = 0

    [array]$outputlineArray = $null
    # loop over line by line

    $startingBlock = "{
    `"schemaVersion`": `"1.2`",
    `"description`": `"$description`",
    `"parameters`": {

    },
    `"runtimeConfig`": {
    `"aws:runPowerShellScript`": {
        `"properties`": [
            {
                `"id`": `"0.aws:runPowerShellScript`",
                `"timeoutSeconds`": $timeOut,
                `"runCommand`": ["

    $finishBlock = "                    ]
                }
            ]
        }
    }
}"

    $outputlineArray += $startingBlock

    ForEach ($scriptLine in $scriptLines) {


        # perform replacements as necessary
        $scriptLine = $scriptLine.replace("\","\\")
        $scriptLine = $scriptLine.replace('"','\"')
        $scriptLine = $scriptLine.replace('`t','    ')
        $scriptLine = $scriptLine.replace('	', '    ')

        If ($lineCount -lt $totalLines -1) {
            # wrap whole line in "<line>",
            $newLine = '                        "'+  $scriptLine + '",'
        }

        Else {
            # wrap last line in "<line>"
            $newLine = '                        "' + $scriptLine + '"'
        }


        # add the line to the array
        $outputlineArray += $newLine
        $lineCount++

    }
    $outputlineArray += $finishBlock
    $outputlineArray | Set-Content -Path $targetScript

}

$src = "C:\Temp\Script.ps1"
$target = "C:\Temp\Script.json"

$desc = "Script description here"
$timeOut = "7200"
Convert-PSScriptToSSM -sourceScript $src -targetScript $target -description $desc -timeOut $timeOut
