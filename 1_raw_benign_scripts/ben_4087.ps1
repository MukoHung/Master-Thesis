function Get-DirectoryName($initialDirectory)
{
    [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null

    $openFolderDialog = New-Object System.Windows.Forms.FolderBrowserDialog
    $openFolderDialog.ShowDialog() | Out-Null
    return $openFolderDialog.SelectedPath
}

Write-Output "Select image folder"
$folderPath = Get-DirectoryName -initialDirectory "~"

Write-Output "Selected $folderPath"
$files = Get-ChildItem "$folderPath\*" -Include *.png,*.jpg,*.bmp
$outFilePath = Join-Path $folderPath "out.txt"

foreach ($file in $files)
{
    $imagePath = Join-Path $folderPath $file.Name
    $txtFileName = $file.BaseName
    $txtPath = Join-Path $folderPath $txtFileName
    Write-Output "$imagePath $txtPath"

    # Actually do OCR - You have to add tesseract to your PATH, or specify its full path here
    tesseract $imagePath $txtPath

    # tesseract adds .txt to out files
    $txtPath = $txtPath + ".txt"

    # Write to single out file
    $txtPath | Out-File $txtPath -Append -Encoding ascii
    Get-Content $txtPath | Out-File $outFilePath -Append
    Remove-Item $txtPath
}