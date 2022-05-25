[CmdletBinding()] Param (
    [Parameter(Position = 0, Mandatory = $True, ValueFromPipelineByPropertyName = $True)]
    [ValidateNotNullOrEmpty()]
    [Alias('FullName')]
    [String]
    $filePath
)

function ConvertFrom-md($mdText){
  $response = Invoke-WebRequest -Uri 'https://api.github.com/markdown/raw' -Method Post -body "$mdText" -ContentType "text/plain"
  return $response.Content
}


#get the full path
$fullPath = Resolve-Path $filePath

#Get Text
$mdt = [String]::Join([environment]::NewLine, (Get-Content $fullPath)); #Get-Content loses linebreaks for some reason.

#Convert And Save to a temp file (warning, will overwrite)
(ConvertFrom-md $mdt) | Out-File $env:TEMP\markdown.html

#Launch in browser
& start iexplore $env:temp\markdown.html
