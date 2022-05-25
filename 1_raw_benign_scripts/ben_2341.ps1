param([string]$repo, [string]$source,[string]$dest)

$base = "$/MAPS Onboard/Dev/$repo"

set-alias tf 'C:\Program Files (x86)\Microsoft Visual Studio 11.0\Common7\IDE\TF.exe'

tf get /recursive "$base/$source"

tf merge /recursive "$base/$source" "$base/$dest"

tf checkin /comment:"merge $source -> $dest"