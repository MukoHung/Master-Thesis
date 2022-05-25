function New-Dictionary {
  <#
  .SYNOPSIS
  Collects the pipeline into a new instance of [System.Collections.Generic.Dictionary[object, object]].

  .DESCRIPTION
  If invoked without pipeline input, then New-Dictionary creates an empty
  dictionary, except for any (optional) arguments to the constructor. If used in
  a pipeline, then New-Dictionary collects the pipeline into a dictionary,
  whereby the collection mechanism is determined by any combination of one of
  the four Key* parameters ($Key, $KeyMemberName, $KeyScriptBlock, or
  $KeyLiteralValue) and one of the four Value* parameters ($Value,
  $ValueMemberName, $ValueScriptBlock, or $ValueLiteralValue).

  .PARAMETER Key
  Parameter description

  .PARAMETER KeyMemberName
  Parameter description

  .PARAMETER KeyScriptBlock
  Parameter description

  .PARAMETER KeyLiteralValue
  Parameter description

  .PARAMETER Value
  Parameter description

  .PARAMETER ValueMemberName
  Parameter description

  .PARAMETER ValueScriptBlock
  Parameter description

  .PARAMETER ValueLiteralValue
  Parameter description

  .PARAMETER ArgumentList
  Parameter description

  .PARAMETER InputObject
  Parameter description

  .EXAMPLE
  An example

  .NOTES
  General notes
  #>
  [CmdletBinding(DefaultParameterSetName = 'NoInput', PositionalBinding = $false)]
  param(
    [Parameter(ParameterSetName = 'Key, Value',             Mandatory, ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName = 'Key, ValueMemberName',   Mandatory, ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName = 'Key, ValueScriptBlock',  Mandatory, ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName = 'Key, ValueLiteralValue', Mandatory, ValueFromPipelineByPropertyName)]
    [PSObject]
    $Key,

    [Parameter(ParameterSetName = 'KeyMemberName, Value',             Mandatory, Position = 0)]
    [Parameter(ParameterSetName = 'KeyMemberName, ValueMemberName',   Mandatory, Position = 0)]
    [Parameter(ParameterSetName = 'KeyMemberName, ValueScriptBlock',  Mandatory, Position = 0)]
    [Parameter(ParameterSetName = 'KeyMemberName, ValueLiteralValue', Mandatory, Position = 0)]
    [String]
    [ValidateNotNullOrEmpty()]
    [Alias('kpn')]
    $KeyMemberName,

    [Parameter(ParameterSetName = 'KeyScriptBlock, Value',             Mandatory, Position = 0)]
    [Parameter(ParameterSetName = 'KeyScriptBlock, ValueMemberName',   Mandatory, Position = 0)]
    [Parameter(ParameterSetName = 'KeyScriptBlock, ValueScriptBlock',  Mandatory, Position = 0)]
    [Parameter(ParameterSetName = 'KeyScriptBlock, ValueLiteralValue', Mandatory, Position = 0)]
    [ScriptBlock]
    [ValidateNotNullOrEmpty()]
    [Alias('ksb')]
    $KeyScriptBlock,

    [Parameter(ParameterSetName = 'KeyLiteralValue, Value',             Mandatory)]
    [Parameter(ParameterSetName = 'KeyLiteralValue, ValueMemberName',   Mandatory)]
    [Parameter(ParameterSetName = 'KeyLiteralValue, ValueScriptBlock',  Mandatory)]
    [Parameter(ParameterSetName = 'KeyLiteralValue, ValueLiteralValue', Mandatory)]
    [PSObject]
    [Alias('klv')]
    $KeyLiteralValue,

    [Parameter(ParameterSetName = 'Key, Value',             Mandatory, ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName = 'KeyMemberName, Value',   Mandatory, ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName = 'KeyScriptBlock, Value',  Mandatory, ValueFromPipelineByPropertyName)]
    [Parameter(ParameterSetName = 'KeyLiteralValue, Value', Mandatory, ValueFromPipelineByPropertyName)]
    [PSObject]
    $Value,

    [Parameter(ParameterSetName = 'Key, ValueMemberName',             Mandatory)]
    [Parameter(ParameterSetName = 'KeyMemberName, ValueMemberName',   Mandatory, Position = 1)]
    [Parameter(ParameterSetName = 'KeyScriptBlock, ValueMemberName',  Mandatory, Position = 1)]
    [Parameter(ParameterSetName = 'KeyLiteralValue, ValueMemberName', Mandatory)]
    [String]
    [ValidateNotNullOrEmpty()]
    [Alias('vpn')]
    $ValueMemberName,

    [Parameter(ParameterSetName = 'Key, ValueScriptBlock',             Mandatory)]
    [Parameter(ParameterSetName = 'KeyMemberName, ValueScriptBlock',   Mandatory, Position = 1)]
    [Parameter(ParameterSetName = 'KeyScriptBlock, ValueScriptBlock',  Mandatory, Position = 1)]
    [Parameter(ParameterSetName = 'KeyLiteralValue, ValueScriptBlock', Mandatory)]
    [ScriptBlock]
    [ValidateNotNullOrEmpty()]
    [Alias('vsb')]
    $ValueScriptBlock,

    [Parameter(ParameterSetName = 'Key, ValueLiteralValue',             Mandatory)]
    [Parameter(ParameterSetName = 'KeyMemberName, ValueLiteralValue',   Mandatory)]
    [Parameter(ParameterSetName = 'KeyScriptBlock, ValueLiteralValue',  Mandatory)]
    [Parameter(ParameterSetName = 'KeyLiteralValue, ValueLiteralValue', Mandatory)]
    [PSObject]
    [Alias('vlv')]
    $ValueLiteralValue,

    [Parameter(ParameterSetName = 'NoInput')]
    [Parameter(ParameterSetName = 'Key, Value')]
    [Parameter(ParameterSetName = 'Key, ValueLiteralValue')]
    [Parameter(ParameterSetName = 'Key, ValueMemberName')]
    [Parameter(ParameterSetName = 'Key, ValueScriptBlock')]
    [Parameter(ParameterSetName = 'KeyLiteralValue, Value')]
    [Parameter(ParameterSetName = 'KeyLiteralValue, ValueLiteralValue')]
    [Parameter(ParameterSetName = 'KeyLiteralValue, ValueMemberName')]
    [Parameter(ParameterSetName = 'KeyLiteralValue, ValueScriptBlock')]
    [Parameter(ParameterSetName = 'KeyMemberName, Value')]
    [Parameter(ParameterSetName = 'KeyMemberName, ValueLiteralValue')]
    [Parameter(ParameterSetName = 'KeyMemberName, ValueMemberName')]
    [Parameter(ParameterSetName = 'KeyMemberName, ValueScriptBlock')]
    [Parameter(ParameterSetName = 'KeyScriptBlock, Value')]
    [Parameter(ParameterSetName = 'KeyScriptBlock, ValueLiteralValue')]
    [Parameter(ParameterSetName = 'KeyScriptBlock, ValueMemberName')]
    [Parameter(ParameterSetName = 'KeyScriptBlock, ValueScriptBlock')]
    [Object[]]
    [ValidateNotNull()]
    [AllowEmptyCollection()]
    [Alias('al')]
    $ArgumentList = @(),

    [Parameter(ParameterSetName = 'Key, Value',                         ValueFromPipeline)]
    [Parameter(ParameterSetName = 'Key, ValueLiteralValue',             ValueFromPipeline)]
    [Parameter(ParameterSetName = 'Key, ValueMemberName',               ValueFromPipeline)]
    [Parameter(ParameterSetName = 'Key, ValueScriptBlock',              ValueFromPipeline)]
    [Parameter(ParameterSetName = 'KeyLiteralValue, Value',             ValueFromPipeline)]
    [Parameter(ParameterSetName = 'KeyLiteralValue, ValueLiteralValue', ValueFromPipeline)]
    [Parameter(ParameterSetName = 'KeyLiteralValue, ValueMemberName',   ValueFromPipeline)]
    [Parameter(ParameterSetName = 'KeyLiteralValue, ValueScriptBlock',  ValueFromPipeline)]
    [Parameter(ParameterSetName = 'KeyMemberName, Value',               ValueFromPipeline)]
    [Parameter(ParameterSetName = 'KeyMemberName, ValueLiteralValue',   ValueFromPipeline)]
    [Parameter(ParameterSetName = 'KeyMemberName, ValueMemberName',     ValueFromPipeline)]
    [Parameter(ParameterSetName = 'KeyMemberName, ValueScriptBlock',    ValueFromPipeline)]
    [Parameter(ParameterSetName = 'KeyScriptBlock, Value',              ValueFromPipeline)]
    [Parameter(ParameterSetName = 'KeyScriptBlock, ValueLiteralValue',  ValueFromPipeline)]
    [Parameter(ParameterSetName = 'KeyScriptBlock, ValueMemberName',    ValueFromPipeline)]
    [Parameter(ParameterSetName = 'KeyScriptBlock, ValueScriptBlock',   ValueFromPipeline)]
    [PSObject]
    $InputObject
  )
  begin {
    $Dictionary = New-Object 'System.Collections.Generic.Dictionary[Object?, Object?]' -ArgumentList $ArgumentList

    $NoInput = $PSCmdlet.ParameterSetName -eq 'NoInput'
    if ($NoInput) {
      return
    }

    $KeyGetter =
      switch -wildcard ($PSCmdlet.ParameterSetName) {
        'Key, *'             { { $Key }.GetNewClosure() }
        'KeyLiteralValue, *' { { $KeyLiteralValue }.GetNewClosure() }
        'KeyMemberName, *'   { { ForEach-Object -MemberName $KeyMemberName -InputObject $_ }.GetNewClosure() }
        'KeyScriptBlock, *'  { $_ }
        default { throw "Unrecognized key component of parameter set ""$_"""}
      }

    $ValueGetter =
      switch -wildcard ($PSCmdlet.ParameterSetName) {
        '*, Value'             { { $Value }.GetNewClosure() }
        '*, ValueLiteralValue' { { $ValueLiteralValue }.GetNewClosure() }
        '*, ValueMemberName'   { { ForEach-Object -MemberName $ValueMemberName -InputObject $_ }.GetNewClosure() }
        '*, ValueScriptBlock'  { $_ }
        default { throw "Unrecognized value component of parameter set ""$_"""}
      }
  }
  process {
    if ($NoInput) {
      return
    }

    $ResolvedKey   = $_ | & $KeyGetter
    $ResolvedValue = $_ | & $ValueGetter

    $Dictionary[$ResolvedKey] = $ResolvedValue
  }
  end {
    $Dictionary
  }
}
