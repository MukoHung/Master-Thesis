# Define external script paths and arguments
$ExternalScript_FullPath = "$((Get-Item $MyInvocation.MyCommand.Path).Directory.FullName)\ExternalScript.ps1"
$ExternalScript_Args = @{
    $param = $value
}

# Run External Script and save output to variable
Invoke-Expression "$ExternalScript_FullPath @ExternalScript_Args" | Tee-Object -Variable ExternalScript_Output

# Show output
$ExternalScript_Output