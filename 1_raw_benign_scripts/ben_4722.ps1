function Edit-XmlNodes {
param (
    [xml] $doc = $(throw "doc is a required parameter"),
    [string] $xpath = $(throw "xpath is a required parameter"),
    [string] $value = $(throw "value is a required parameter"),
    [bool] $condition = $true
)    
    if ($condition -eq $true) {
        $nodes = $doc.SelectNodes($xpath)
         
        foreach ($node in $nodes) {
            if ($node -ne $null) {
                if ($node.NodeType -eq "Element") {
                    $node.InnerXml = $value
                }
                else {
                    $node.Value = $value
                }
            }
        }
    }
}

$xml = [xml](Get-Content "c:\my\file.xml")
# <file><foo attribute="bar" attribute2="bar" attribute3="bar" /></file>

Edit-XmlNodes $xml -xpath "/file/foo[@attribute='bar']/@attribute" -value "new value"

$xml.save("c:\my\file.xml")
# <file><foo attribute="new value" attribute2="bar" attribute3="bar" /></file>
