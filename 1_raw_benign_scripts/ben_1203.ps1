Param(
    [Parameter(Mandatory=$True)]
    [string]$FilePath
)
 
$Files = Get-ChildItem "$FilePath\*.docx"
 
$Word = New-Object -ComObject Word.Application
 
Foreach ($File in $Files) {
    # open a Word document, filename from the directory
    $Doc = $Word.Documents.Open($File.FullName)
 
    # Swap out DOCX with PDF in the Filename
	  $Name=($Doc.FullName).Replace("docx","pdf")
 
    # Save this File as a PDF in Word 2010/2013
    $Doc.SaveAs([ref] $Name, [ref] 17)
    $Doc.Close()
}