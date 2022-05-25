# https://aws.amazon.com/blogs/developer/handling-credentials-with-aws-tools-for-windows-powershell/

# Set-AWSCredentials -StoredCredentials default
$region = "us-east-2"
$key = 'OIDC_ISSUER_URL'
$value = "https://cognito-idp.us-east-2.amazonaws.com"
$stage = "dev"

$OutputFolder = [IO.Path]::Combine($pwd,"updateLambdaFunction")
$OutputFolder = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputFolder)
If(!(test-path $OutputFolder))
{
    $_ = New-Item -ItemType Directory -Force -Path $OutputFolder;
}
$result = @()
$lambdas = $(Get-LMFunctionlist -Region $region) | Where {$_.FunctionName -and $_.FunctionName.Contains("-$stage") -and ($_.FunctionName.Contains('-app') -or $_.FunctionName.Contains('-flask') -or $_.FunctionName.Contains('-service'))} | Select -ExpandProperty FunctionName

foreach ($functionName in $lambdas) {
    $environment=(Get-LMFunctionConfiguration -FunctionName $functionName -Region $region)
    if($null -ne $environment.Environment.Variables -and $environment.Environment.Variables.ContainsKey($key))
    {
        $oldValue = $environment.Environment.Variables[$key]
        $environmentBackup = "$([IO.Path]::Combine($OutputFolder, "config-$stage.$($functionName).$(get-date -f yyyyMMdd).json"))"
        if(!(Test-Path $environmentBackup))
        {
            $environment.Environment.Variables | ConvertTo-Json -depth 100 | Out-File $environmentBackup
        }
        if($environment.Environment.Variables[$key] -ne $value)
        {
            $environment.Environment.Variables[$key] = $value
            Update-LMFunctionConfiguration -FunctionName $functionName -Region $region -Environment_Variable $environment.Environment.Variables
            $new_environment=(Get-LMFunctionConfiguration -FunctionName $functionName -Region $region)
            $newValue = $new_environment.Environment.Variables[$key]
            $item = [pscustomobject]@{
                "FunctionName" = $functionName
                "OldValue" = $oldValue
                "NewValue" = $newValue
                "Date" = $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')
            }
            ($item | fl)
            $result+=$item
        }
        else
        {
            Write-Host "$($functionName).$($key) already equals $($environment.Environment.Variables[$key])"
        }
    }
}

$result | ft

$result | Select FunctionName, OldValue, NewValue, Date | Export-Csv -LiteralPath "$([IO.Path]::Combine($OutputFolder, 'updateLambdaEnvironment.csv'))" -NoTypeInformation -append
