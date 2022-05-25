[xml]$config = (& "$env:WINDIR\system32\inetsrv\appcmd.exe" list config /section:httpCompression)

if ($config -ne $null -and ($config.GetElementsByTagName("httpCompression") -ne $null)) {
    $compression = $config.GetElementsByTagName("httpCompression")[0]
    
    $dynamic = $compression.dynamicTypes 
    EnableCompression $dynamic "dynamicTypes" "application/x-javascript"
    EnableCompression $dynamic "dynamicTypes" "application/atom+xml"
}

function EnableCompression([System.Xml.XmlElement]$node, [string]$nodeName, [string]$mimeType) {
    $appCmdMimeType = $mimeType.Replace("+", "%u002b")

    if (Is-CompressionSet $node $mimeType) {
        Write-Host "Compression setting for $nodeName::'$mimeType' ($appCmdMimeType) exists, clearing it..."
        & "$env:WINDIR\system32\inetsrv\appcmd.exe" set config -section:system.webServer/httpCompression /-"$nodeName.[mimeType='$appCmdMimeType']" /commit:appHost;
    }
    else {
        Write-Host "Compression for $nodeName::'$mimeType' ($appCmdMimeType) was not already set. Didn't need to clear the setting."
    }

    & "$env:WINDIR\system32\inetsrv\appcmd.exe" set config -section:system.webServer/httpCompression /+"$nodeName.[mimeType='$appCmdMimeType',enabled='True']" /commit:apphost;
}

function Is-CompressionSet([System.Xml.XmlElement]$node, [string]$mimeType) {
    return `
        ($node -ne $null) `
        -and ($node.SelectSingleNode("add[@mimeType='$mimeType']") -ne $null);
}