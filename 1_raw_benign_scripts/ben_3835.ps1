# Modified from: http://stackoverflow.com/a/11010158/215200

$fromFolder = "D:\FOLDER\"
$rootName = "FILENAME"
$ext = "EXT"

$from = "{0}{1}.{2}" -f ($fromFolder, $rootName, $ext)
$fromFile = [io.file]::OpenRead($from)

$upperBound = 100MB
$buff = new-object byte[] $upperBound

$count = $idx = 0

try {
    "Splitting $from using $upperBound bytes per file."
    do {
        $count = $fromFile.Read($buff, 0, $buff.Length)
        if ($count -gt 0) {
            $to = "{0}{1}.{2}.{3}" -f ($fromFolder, $rootName, $idx, $ext)
            $toFile = [io.file]::OpenWrite($to)
            try {
                "Writing to $to"
                $tofile.Write($buff, 0, $count)
            } finally {
                $tofile.Close()
            }
        }
        $idx ++
    } while ($count -gt 0)
}
finally {
    $fromFile.Close()
}
