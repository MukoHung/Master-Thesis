
$sdirs = @(
	"C:\Users\jesse_b"
	#"C:\Users\jesse_b\tmp"
)

$ddir = "Y:\jesse"
#$ddir = "C:\Users\jesse_b\tmp\test"

function fsync ($source,$target) {

    $sourceFiles = @(Get-ChildItem -Path $source -Recurse | select -expand FullName)

    foreach ($f in $sourceFiles) {
        $destFile = $f.Replace($source,$target)
        $exist = Test-Path -LiteralPath $destFile

        if ($exist -eq $false) {
            Copy-Item -LiteralPath "$f" -Destination "$destFile"
        }
    }
}

foreach ($e in $sdirs) {
	fsync $e $ddir
}
