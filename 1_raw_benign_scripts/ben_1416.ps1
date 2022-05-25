# set working directory to this script place
$wkdir = Split-Path $myInvocation.MyCommand.path
cd $wkdir

# load settings
. .\test_settings.ps1
# . .\user_settings.ps1

trap
{
    "An exception has occurred."
    exit
}

if ((Test-Path $settings.tgtDir) -and (Test-Path (Split-Path $settings.outFileCsv -Parent)) -and
    (Test-Path $settings.vbaFileXls) -and (Test-Path (Split-Path $settings.outFileXls -Parent))) {
        $settings.tgtDir = Convert-Path $settings.tgtDir
        $settings.outFileCsv = (Convert-Path (Split-Path $settings.outFileCsv -Parent)) + "\" + (Split-Path $settings.outFileCsv -Leaf)
        $settings.vbaFileXls = Convert-Path $settings.vbaFileXls
        $settings.outFileXls = (Convert-Path (Split-Path $settings.outFileXls -Parent)) + "\" + (Split-Path $settings.outFileXls -Leaf)
    } else {
        Write-host "Loaded settings contains invaild paths. Confirm the settings."
        exit
}

# Write-Host "The settings are as follows.`r`n $tgtDir`r`n $outFileCsv`r`n $vbaFileXls`r`n $outFileXls"

# generatie outfile suffix
$suffix = get-date -Format yyyyMMdd.hhss

Write-Host "Exporting file list..."

# Export file list to csv
.\lsParentDir2.ps1 $settings.tgtDir $settings.outFileCsv

# Insert suffix
# if ($settings.outFileXls -match "\.") {
#     $settings.outFileXls = $settings.outFileXls -replace "\.[^\.]+$", ".$suffix.xls"
# } else {
#     $settings.outFileXls += ".$suffix.xls"
# }

# call Excel Macro
.\callExcelVBA.ps1 $settings.vbaFileXls $settings.vbaScr $settings.outFileCsv $settings.outFileXls
Write-Host "Exporting is done."
