#requires -module Indented.StubCommand

function Enable-AutoMockRecord ([Switch]$Append) {
    $env:AUTOMOCK_RECORD = $true
    if ($Append) {$env:AUTOMOCK_APPEND = $true}
}
function Disable-AutoMockRecord {
    Remove-Item env:AUTOMOCK_RECORD -ErrorAction SilentlyContinue
    Remove-Item env:AUTOMOCK_APPEND -ErrorAction SilentlyContinue
}
function AutoMock {
    <#
    .SYNOPSIS
    Mock a command and record the output stream to cache files, then replay on request
    .DESCRIPTION
    By default this runs in "replay mode", meaning that it will error if a matching mock for the command is not found.
    Set $DebugPreference='continue' to view when mocks have been recorded or replayed.
    .OUTPUTS
    None
    .EXAMPLE
    AutoMock Invoke-RestMethod -Record
    PS>Invoke-RestMethod -Uri 'https://ipinfo.io/json'
    Record a command for later playback

    PS>AutoMock Invoke-Restmethod
    #This command will return the cached result
    PS>Invoke-RestMethod -Uri 'https://ipinfo.io/json'

    #This command will error with a "mock not found" error
    PS>Invoke-RestMethod -Uri 'https://ipinfo.io/1.1.1.1/json'

    #>
    [CmdletBinding(DefaultParameterSetName='Replay')]
    param (
        #The name of the command or commands to record for AutoMock
        [Parameter(Mandatory,ValueFromPipeline,Position=0)]$CommandName,
        #Location to store and replay. Uses your default temporary directory by default.
        [String]$Path = [IO.Path]::GetTempPath(),
        #Record all outputs, overwriting any existing outputs
        [Parameter(ParameterSetName='Record')][Switch]$Record = ([bool]$ENV:AUTOMOCK_RECORD),
        #Only record items that have not been recorded before, and replay otherwise. Not recommended.
        [Parameter(ParameterSetName='Record')][Switch]$Append = ([bool]$ENV:AUTOMOCK_APPEND),
        #Specify this if you want to disable automock functionality. Useful for "live" testing or acceptance testing without having to write separate code
        [Parameter(ParameterSetName='Disable')][Switch]$Disable = ([bool]$ENV:AUTOMOCK_DISABLE),
        #Clear any previously stored cache items first. This will clear ALL cache, not just for the command you specified.
        #To clear cache for specific entries, watch the debug output and remove those specific files.
        [Parameter(ParameterSetName='Record')][Switch]$Reset

    )
    begin {
        #Some environment variables for use when running with pester or in an environment
        if ($ENV:AUTOMOCK_PATH) {$Path = $ENV:AUTOMOCK_PATH}

        #ParameterSet doesn't change even if variable default is set via environment variable
        if ($Record -or $Append -or $Reset) {
            $AutoMockRecordMode = $true
            write-debug "AutoMock: Running in Record mode"
        } elseif ($Disable) {
            write-debug "AutoMock: Running in Disabled mode"
        } else {
            write-debug "AutoMock: Running in Replay mode"
        }

        if (-not $Disable -and -not $AutoMockRecordMode -and -not (Get-ChildItem -Path (Join-Path $Path '*.clixml'))) {
            throw "No AutoMocks were found in $Path. Did you run this command with -Record first to record outputs?"
        }
    }

    process {
        if (-not $CommandName) {continue}
        $AutoMockBaseName = 'AutoMock'
        $AutoMockFunctionName = "Invoke-$AutoMockBaseName-$(New-Guid)"
        $AutoMockBaseFileName = "$AutoMockBaseName-$CommandName".Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
        $ReplayStubPath = (Join-Path $Path "$AutoMockBaseFileName.ps1")
        #Replace any invalid filename characters
        $ReplayStubPath = $ReplayStubPath

        #Detect if automocked already
        $ExistingAlias = Get-Alias $CommandName -ErrorAction SilentlyContinue
        if ($ExistingAlias) {
            if ($ExistingAlias.Definition.StartsWith('Invoke-AutoMock')) {
                if ($Disable) {
                    write-debug "AutoMock: DISABLING $CommandName"
                } else {
                    write-warning "$CommandName has already been AutoMocked, replacing the existing mock"
                }
                Remove-Item "Alias:/$CommandName"
                Remove-Item "Function:/$($ExistingAlias.Definition)"
            } else {
                throw "It appears you are attempting to automock $CommandName which is currently an alias. This is not supported by AutoMock. Please mock $($ExistingAlias.Definition) instead"
            }
        }
        #If disabled, move on without action
        if ($Disable) {continue}

        #Replay Mode: Fetch the command and import it
        if (-not $AutoMockRecordMode) {
            if (-not (Test-Path $ReplayStubPath)) {
                throw "AutoMock: Mock for $CommandName not found at $ReplayStubPath. HINT: Did you specify the correct -Path argument, and did you run -Record first?"
            }

            Write-Debug "AutoMock: Replay Mock Definition found for $CommandName at $ReplayStubPath. Loading..."
            . $ReplayStubPath
            return
        } else {
            if ($Reset) {
                try {
                    Write-Debug "AutoMock: resetting $CommandName cache at $Path"
                    Remove-Item "$Path/$AutoMockBaseName-$CommandName-*.clixml" -ErrorAction Stop
                    Remove-Item $ReplayStubPath -ErrorAction Stop
                } catch [Management.Automation.ItemNotFoundException] {}
            }
        }

        $stubDefinition = New-StubCommand -CommandName $CommandName -FunctionBody {
            begin {
                $SCRIPT:AutoMockPipelineInput = [Collections.Generic.List[Object]]::new()
                $Path = ${PATH}
                $record = ${RECORD}
                $append = ${APPEND}
                $CommandName = ${COMMANDNAME}
            }
            process {
                #Collect the pipeline input to be used by steppable pipeline later
                $AutoMockPipelineInput.Add($PSItem)
            }
            end {
                function Get-ObjectHash ($InputObject, $Depth = 5) {
                <#
                .SYNOPSIS
                Get a JSON representation of an object and take the hash of it
                This is meant to be like GetObjectHash() but cross-platform and cross-version
                #>
                    $ObjectSerialization = ConvertTo-Json -InputObject $InputObject -Depth $Depth -Compress
                    write-debug "AutoMock: Hash JSON - $ObjectSerialization"
                    $InputStream = [IO.MemoryStream]::new(
                        [text.encoding]::UTF8.GetBytes(
                            $ObjectSerialization
                        )
                    )

                    (Get-FileHash -Algorithm SHA1 -InputStream $InputStream).hash
                }

                $commandString = $CommandName + [Environment]::NewLine + ($PSBoundParameters | Out-String)
                write-debug "AutoMock: Attempting to mock $CommandString"
                $commandHash = Get-ObjectHash @(
                    $CommandName
                    $PSBoundParameters
                    $AutoMockPipelineInput
                )
                $MockFileName = "AutoMock-$CommandName-$commandHash.clixml".Split([IO.Path]::GetInvalidFileNameChars()) -join '_'
                $MockPath = Join-Path $Path $MockFileName

                if (Test-Path $MockPath) {
                    if (-not $Record -or $Append) {
                        Write-Debug "AutoMock: FOUND at $MockPath"
                        return (Import-Clixml $MockPath)
                    }
                } else {
                    if (-not $Record) {
                        throw ("AutoMock: NOT FOUND at $MockPath for the following command:" + [Environment]::NewLine + $CommandString)
                    }
                }

                #RECORD: If we get this far, record the output

                function Invoke-SteppablePipeline {
                <#
                .SYNOPSIS
                We have to wrap the steppable pipeline in a function in order to handle the return output, since it hands off to the parent function to handle by default
                #>
                    [CmdletBinding()]
                    param(
                        [Parameter(Mandatory)]
                        $Command,
                        $BoundParameters,
                        $AutoMockPipelineInput
                    )

                    #Fetch the command we are mocking for invocation
                    [String[]]$commandTypeFilter = [Management.Automation.CommandTypes]::GetNames([Management.Automation.CommandTypes]).where{$_ -notmatch 'All|Alias|Application|Workflow|Configuration'}
                    $MockedCommand = Get-Command $Command -CommandType $commandTypeFilter -ErrorAction stop
                    $scriptCmd = { &($MockedCommand) @BoundParameters }
                    $steppablePipeline = $scriptCmd.GetSteppablePipeline()
                    if ($AutoMockPipelineInput) { $ExpectingPipelineInput = $true }
                    $steppablePipeline.Begin($ExpectingPipelineInput, $ExecutionContext)
                    Foreach ($AutoMockPipelineItem in $AutoMockPipelineInput) {
                        $steppablePipeline.Process($AutoMockPipelineItem)
                    }
                    $steppablePipeline.End()
                }
                try {
                    Invoke-SteppablePipeline -Command $CommandName -BoundParameters $PSBoundParameters -AutoMockPipelineInput $AutoMockPipelineInput -OutVariable AutoMockResult
                } catch {
                    Write-Debug "AutoMock: ERROR Captured - $PSItem"
                    Write-Debug "Saving Error in $CommandName to $MockPath"
                    $PSItem | Export-Clixml $MockPath
                    throw
                }
                Write-Debug "AutoMock: RECORD $CommandName to $MockPath"
                $AutoMockResult | Export-Clixml $MockPath
            }
        }

        #TODO: Fix this hacky pipeline fix for Implicitly remoted commands
        if ($stubDefinition -match 'ValueFromPipeline') {
            $LineRemoveRegex = [Regex]::Escape('if ($AutoMockPipelineInput) { $ExpectingPipelineInput = $true }')
            $stubdefinition = $stubDefinition -replace $LineRemoveRegex,'$AutoMockPipeLineInput=$null;if ($AutoMockPipelineInput) { $ExpectingPipelineInput = $true }'
        }

        #Set the redirection alias for the command
        $AliasDefinition = "New-Alias -Name '$CommandName' -Value '$AutoMockFunctionName' -Force -Scope SCRIPT"

        # Import the 'Record' function into the global scope and substitute common settings
        $CommandNameRegexMatch = [Regex]::Escape("function $CommandName {")
        $stubDefinition = $stubDefinition -replace "^$CommandNameRegexMatch","function SCRIPT:$AutoMockFunctionName {"
        $stubdefinition = $stubdefinition -replace '\${COMMANDNAME}', "'$CommandName'"

        #Write the "Replay" function to the automock folder
        if ($Record) {
            $replayStubDefinition = $stubDefinition
            $replayStubDefinition = $replayStubDefinition -replace '\${PATH}', '$PSScriptRoot'
            $replayStubDefinition = $replayStubDefinition -replace '{RECORD}', "$false"
            $replayStubDefinition = $replayStubDefinition -replace '{APPEND}', "$false"
            Write-Debug "AutoMock: Saving Replay AutoMock for $CommandName to $ReplayStubPath"
            ($replayStubDefinition + [Environment]::NewLine + $AliasDefinition) > $ReplayStubPath
        }
        $stubdefinition = $stubdefinition -replace '\${PATH}', "'$Path'"
        $stubdefinition = $stubdefinition -replace '{RECORD}', "$Record"
        $stubdefinition = $stubdefinition -replace '{APPEND}', "$Append"
        ($stubDefinition + [Environment]::NewLine + $AliasDefinition) | Invoke-Expression

    }
}