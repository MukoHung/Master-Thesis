param(
    [string]$url
)

youtube-dl `
$url `
--quiet `
--extract-audio `
--audio-format mp3 `
--audio-quality 3 `
--exec 'mp3gain -q -r -c "{}"'
