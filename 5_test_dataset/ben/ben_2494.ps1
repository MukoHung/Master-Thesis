##################################################################
#
#   Requires Windows PowerShell v2 - v5
#   Will not work in PS 7+ due to lack of ParsedHtml functionality
#
##################################################################

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$skuPage = Invoke-WebRequest "https://docs.microsoft.com/en-us/azure/active-directory/enterprise-users/licensing-service-plan-reference"

# Extract the sku table from the sku page
$skuTable = @($skuPage.ParsedHtml.getElementsByTagName("TABLE"))[0]
$headers = @()
$tableRows = @($skuTable.Rows)
$SkuList = @{}
$ti = (Get-Culture).TextInfo

# For each html row in the html table
foreach($row in $tableRows)
{
    $cells = @($row.Cells)
   
    # If we've found a table header, remember its headers
    if($cells[0].tagName -eq "TH")
    {
        $headers = @($cells | % { ("" + $_.InnerText).Trim() })
        continue
    }

    # Find headers
    $license = [Ordered] @{}
    for($i = 0; $i -lt $cells.Count; $i++)
    {
        $header = $headers[$i]
        if(-not $header) { continue }  

        $license[$header] = ("" + $cells[$i].InnerText).Trim()
    }

    # Add license to hashtable using the string id and converting the product name to capitalised first letter for better presentation
    $SkuList[$license."String ID"] = $ti.ToTitleCase(($license."Product name").ToLower())
}