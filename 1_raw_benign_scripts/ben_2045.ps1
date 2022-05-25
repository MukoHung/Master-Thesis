function Measure-CharacterFrequency
{
    <# 
    
    .SYNOPSIS 
    
    Measures the letter / character frequency in a block of text, ignoring whitespace 
    and PowerShell comment blocks.
    
    Author: Lee Holmes
    Original location: https://raw.githubusercontent.com/PSGumshoe/PSGumshoe/master/PSGumshoe.psm1
    
    #>

    [CmdletBinding(DefaultParameterSetName = "ByPath")]
    param(
        ## The path of items with content
        [Parameter(ParameterSetName = "ByPath", Position = 0)]
        $Path,

        ## The literal path of items with content
        [Parameter(ParameterSetName = "ByLiteralPath", Position = 0, ValueFromPipelineByPropertyName)]
        [Alias("PSPath")]
        $LiteralPath,

        ## The actual content to be measured
        [Parameter(ParameterSetName = "ByContent")]
        [String]
        $Content    
    )

    begin
    {
        $characterMap = @{}
    }

    process
    {
        if($PSCmdlet.ParameterSetName -ne "ByContent")
        {
            ## If the items were piped in or supplied by Path / LiteralPath, get the content of each of them. 
            Get-ChildItem @PSBoundParameters | Foreach-Object {
                $content = Get-Content -LiteralPath $_.FullName -Raw
                
                ## Remove comments and whitespace
                ($content -replace '(?s)<#.*?#>','' -replace '#.*','' -replace '(?s)\s','').ToCharArray() | ForEach-Object {
                    $key = $_.ToString().ToUpper()

                    ## And store the character frequency for each character
                    $characterMap[$key] = 1 + $characterMap[$key] }
            }
        }
        else
        {
            ## Remove comments and whitespace
            ($content -replace '(?s)<#.*?#>','' -replace '#.*','' -replace '\s','').ToCharArray() | ForEach-Object {
                $key = $_.ToString().ToUpper()

                ## And store the character frequency for each character
                $characterMap[$key] = 1 + $characterMap[$key] }
        }   
    }

    end
    {
        ## Figure out how many characters were present in total so that we can calculate a percentage
        $total = $characterMap.GetEnumerator() | Measure-Object -sum Value | ForEach-Object Sum

        ## And generate nice object-based output for each character and its frequency
        $characterMap.GetEnumerator() | Sort-Object -desc value | ForEach-Object {
            [PSCustomObject] @{ Name = $_.Name; Percent = [Math]::Round($_.Value / $total * 100, 3) } }
    }
}

function Measure-VectorSimilarity
{
    <# 
    
    .SYNOPSIS 
    
    Measures the vector / cosine similarity between two sets of items. 
    See: https://en.wikipedia.org/wiki/Cosine_similarity 
    
    Author: Lee Holmes
    Original location: https://raw.githubusercontent.com/PSGumshoe/PSGumshoe/master/PSGumshoe.psm1
    
    .EXAMPLE 
    
    PS > .\Measure-VectorSimilarity.ps1 @(1..10) @(3..8) 
    0.775 
    
    .EXAMPLE 
    
    PS > $items = dir c:\windows\ | Select -First 10 
    PS > $items2 = dir c:\windows\ | Select -First 8 
    PS > .\Measure-VectorSimilarity.ps1 $items $items2 -KeyProperty Name -ValueProperty Length 
    0.894 
    
    #>

    [CmdletBinding()]
    param(
        ## The first set of items to compare
        [Parameter(Position = 0)]
        $Set1,

        ## The second set of items to compare
        [Parameter(Position = 1)]   
        $Set2,
        
        ## If the item sets represent objects that have a main property
        ## (like file names), the name of that key property 
        [Parameter()]
        $KeyProperty,

        ## If the item sets represent objects that have a main property
        ## to represent the values (like Count or Percent),
        ## the name of that key property. If they don't have a property
        ## like this, simple existence of the item will be used. 
        [Parameter()]
        $ValueProperty
    )

    ## If either set is empty, there is no similarity
    if((-not $Set1) -or (-not $Set2))
    {
        return 0
    }

    ## Figure out the unique set of items to be compared - either based on
    ## the key property (if specified), or the item value directly
    $allkeys = @($Set1) + @($Set2) | Foreach-Object {
        if($PSBoundParameters.ContainsKey("KeyProperty")) { $_.$KeyProperty }
        else { $_ }
    } | Sort-Object -Unique

    ## Figure out the values of items to be compared - either based on
    ## the value property (if specified), or the item value directly. Put
    ## these into a hashtable so that we can process them efficiently.

    $set1Hash = @{}
    $set2Hash = @{}
    $setsToProcess = @($Set1, $Set1Hash), @($Set2, $Set2Hash)

    foreach($set in $setsToProcess)
    {
        $set[0] | Foreach-Object {
            if($PSBoundParameters.ContainsKey("ValueProperty")) { $value = $_.$ValueProperty }
            else { $value = 1 }
            
            if($PSBoundParameters.ContainsKey("KeyProperty")) { $_ = $_.$KeyProperty }

            $set[1][$_] = $value
        }
    }

    ## Calculate the vector / cosine similarity of the two sets
    ## based on their keys and values.
    $dot = 0
    $mag1 = 0
    $mag2 = 0

    foreach($key in $allkeys)
    {
        $dot += $set1Hash[$key] * $set2Hash[$key]
        $mag1 +=  ($set1Hash[$key] * $set1Hash[$key])
        $mag2 +=  ($set2Hash[$key] * $set2Hash[$key])
    }

    $mag1 = [Math]::Sqrt($mag1)
    $mag2 = [Math]::Sqrt($mag2)

    ## Return the result
    [Math]::Round($dot / ($mag1 * $mag2), 3)
}

function Invoke-ObfuscationDetection {
    <#
        .SYNOPSIS
        Attempts to detect if a given script appears to be obfuscated.

        Author: @cobbr_io

        .DESCRIPTION
        This function takes a given string (usually containing a powershell
        script) and attempts to detect if it contains an obfuscated powershell
        script.

        .PARAMETER Script
        String containing the script to be checked for obfuscation.

        .PARAMETER ScriptName
        String with a name for the script. Not required, but can be useful
        for correlating detection results with a script when detecting
        against multiple scripts.

        .PARAMETER ScriptPath
        Path containing the script to be checked for obfuscation.

        .PARAMETER RequiredSimilarity
        Optionally specify the required vector similarity to be considered
        unobfuscated.

        .EXAMPLE
        > Invoke-ObfuscatedDetection -Script "Write-Host No obfuscation here!"
        Check if the script "Write-Host No obfuscation here!" is obfuscated.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ParameterSetName="ByContent", Mandatory, ValueFromPipeline, Position=0)]
        [String] $Script,
        [Parameter(ParameterSetName="ByContent", ValueFromPipelineByPropertyName, Position=1)]
        [String] $ScriptName = $null,
        [Parameter(ParameterSetName="ByPath", Mandatory, ValueFromPipelineByPropertyName, Position=0)]
        [ValidateScript({Test-Path $_ -PathType leaf})]
        [Alias('FullName', 'Name')]
        [String[]] $ScriptPath,
        [Parameter()]
        [ValidateRange(0.0,1.0)]
        [Double] $RequiredSimilarity = 0.8
    )
    Begin {
        # Define a "normal" PowerShell character frequency baseline
        $globalFrequencies = @{'E'=9.818; 'T'=7.471;'A'=5.575;'R'=5.464;'S'=5.316;'I'=5.123;'N'=5.066;'O'=5.059;'L'=3.575;'C'=3.253;'M'=3.201;'$'=3.111;'P'=2.875;'D'=2.799;'U'=2.315;'-'=1.932;'.'=1.917;'"'=1.798;'F'=1.696;'G'=1.542;'B'=1.493;'H'=1.474;'='=1.342;'('=1.336;')'=1.33;'Y'=1.193;'W'=1.173;'V'=0.902;'{'=0.771;'}'=0.766;','=0.655;'X'=0.651;'['=0.621;']'=0.62;"'"=0.587;'_'=0.538;':'=0.483;'K'=0.453;'0'=0.45;'/'=0.432;'J'=0.345;'1'=0.316;'+'=0.27;'2'=0.245;'|'=0.238;';'=0.23;'\'=0.222;'Q'=0.218;'>'=0.196;'<'=0.185;'Z'=0.154;'3'=0.133;'*'=0.128;'`'=0.122;'5'=0.114;'4'=0.103;'@'=0.092;'6'=0.087;'8'=0.076;'7'=0.067;'%'=0.063;'9'=0.061;'!'=0.045;'?'=0.035;'&'=0.027}
        $globalFrequencies = $globalFrequencies.GetEnumerator() | Sort-Object -desc value | ForEach-Object {
            [PSCustomObject] @{ Name = $_.Name; Percent = $_.Value }
        }

    }
    Process {
        if($PSCmdlet.ParameterSetName -eq "ByPath") {
            $Script = [IO.File]::ReadAllText((Resolve-Path $ScriptPath))
            $ScriptName = $ScriptPath
        }
        $scriptFrequencies = Measure-CharacterFrequency -Content $Script
        $sim = Measure-VectorSimilarity $globalFrequencies $scriptFrequencies -KeyProperty Name -ValueProperty Percent
        $IsObfuscated = $False
        if($sim -lt $RequiredSimilarity) {
            $IsObfuscated = $True
        }
        if($ScriptName) {
            [PSCustomObject] @{ Name = $ScriptName; Obfuscated = $IsObfuscated }
        }
        else {
            [PSCustomObject] @{ Obfuscated = $IsObfuscated }
        }
    }
}