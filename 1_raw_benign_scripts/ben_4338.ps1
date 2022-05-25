# Get-MimeType (modified, original: https://stackoverflow.com/a/13053795)
function Get-MimeType() {
    param($extension = $null);
    $mimeType = $null;
    if ($null -ne $extension) {
        $drive = Get-PSDrive HKCR -ErrorAction SilentlyContinue;
        if ($null -eq $drive) {
            $drive = New-PSDrive -Name HKCR -PSProvider Registry -Root HKEY_CLASSES_ROOT
        }
        
        try {
            $reg = Get-ItemProperty HKCR:$extension -ErrorAction Stop;
            $mimeType = $reg."Content Type";
        }catch{
            'application/octet-stream'
        }
    }
    $mimeType;
}

if (!$args[0]) {
    Write-Error "No Path Provided";
}

$ext = (Get-Item $args[0]).Extension;
$mimeType = Get-MimeType -extension $ext;

$headers = @{
    "Content-Type" = $mimeType;
};

$url = "https://lolis.love/upload_raw";

$response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -InFile $args[0];
if ($response.success) {
    $response.url;
}