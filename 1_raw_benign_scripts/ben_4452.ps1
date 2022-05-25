param(
    [string]
    $ModuleName = 'nimbus'
)

$module = Get-Module -ListAvailable $ModuleName | Sort-Object -Descending Version | Select-object -First 1
if(!$module)
{
    throw "Module $module not found"
}

$modulePath = $module.Path | Split-Path
$catalogPath = Join-path $modulePath -ChildPath "${ModuleName}.cat"
$psd1Path = Join-path $modulePath -ChildPath "${ModuleName}.psd1"

if(!(Test-Path -Path $catalogPath))
{
    # verified it will only fall back to the manifest
    # https://github.com/PowerShell/PowerShellGetv2/blob/f45bfe1a66df7063aa8de10fc4f147fdc23639af/src/PowerShellGet/private/functions/ValidateAndGet-AuthenticodeSignature.ps1#L71
    $signature = Get-AuthenticodeSignature $psd1Path -errorAction ignore
    if(!$signature)
    {
        throw "$module name is not signed for publisher verification"
    }
    elseif($signature.status -ne "Valid" -or $signature.SignatureType -ne "Authenticode") {
        [pscustomobject] @{
            File    = $psd1Path
            Message = "Signature is not valid: $($signature.status)"
        }
    }
    else{
        Write-verbose "$ModuleName is not catalog signed, only the psd1 will be verified" -Verbose
        Write-verbose "$ModuleName is signed by $($signature.SignerCertificate.Subject)" -Verbose
    }

    return
}
else {
    $signature = Get-AuthenticodeSignature $catalogPath
    if($signature.status -ne "Valid" -or $signature.SignatureType -ne "Authenticode") {
        [pscustomobject] @{
            File    = $catalogPath
            Message = "Signature is not valid: $($signature.status)"
        }
    }
    else{
        Write-verbose "$ModuleName is signed by $($signature.SignerCertificate.Subject)" -Verbose
    }
}

# test the catalog
$testFileCatResults = Test-FileCatalog -CatalogFilePath $catalogPath -Path $modulePath -Detailed -FilesToSkip PSGetModuleInfo.xml

# find all keys
$keys = @()
$keys += $testFileCatResults.PathItems.Keys
$keys += $testFileCatResults.CatalogItems.Keys
$uniqueKeys = $keys | Select-Object -Unique

# loop through all unique keys and compare
foreach ($key in $uniqueKeys) {

    # Get Hashes from catalog test
    $refHash = "$($testFileCatResults.CatalogItems.$key)"
    $diffHash = "$($testFileCatResults.PathItems.$key)"

    Write-Verbose "catalogHash: $refHash ;PathHash: $diffHash"

    # Compare Hashes
    $diff = Compare-Object -ReferenceObject $refHash -DifferenceObject $diffHash

    # Produce result, if there is a diff
    if ($diff) {
        if (!$refHash) {
            $message = "file doesn't exist in catalog"
        } elseif (!$diffHash) {
            $message = "file doesn't exist in module directory"
        } else {
            $message = "Hashes don't match, FileHash: $diffHash; CatalogHash: $refHash"
        }
        [pscustomobject] @{
            File    = $key
            Message = $message
        }
    }
}
