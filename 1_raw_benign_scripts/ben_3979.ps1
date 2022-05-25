$svgs = Get-ChildItem (".\*") -Filter *.svg
$scriptPath = $MyInvocation.MyCommand.Path
$scriptDirectory = Split-Path $scriptPath
$outputDirectory = $scriptDirectory + "\output"

# Replace specific path as needed
$magickExePath = "C:\Program Files\ImageMagick-7.0.8-Q16\magick.exe"

ForEach($svg in $svgs) {
	Write-Host $svg
    $svgQuoted = '"' + $svg + '"'

	$outputFile = Split-Path $svg.Basename -leaf
	$outputFile = $outputFile + '.png'
	
	$pngPath = Join-Path -Path $outputDirectory -ChildPath $outputFile
	$pngPath = '"' + $pngPath + '"'

	$arguments = 'convert','-scale','500x500','-extent','110%x110%','-gravity','center','-background','transparent',$svgQuoted,$pngPath
	& $magickExePath $arguments
}
