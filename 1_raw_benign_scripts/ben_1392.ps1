# PowerShell function to run JavaScript/JQuery and return results back to PS, with timeout

# some web page with jQuery in it
$url = "http://jquery.com/"

Function ResetTimer
{
    $script:startTime = [DateTime]::Now
}

Function IsTimeout([TimeSpan]$timeout)
{
    return ([DateTime]::Now - $startTime) -ge $timeout
}

Function WaitForIE
{
    $ie = $script:ie
    Write-Debug "Waiting..."
    ResetTimer
    do {
        if (IsTimeout ([TimeSpan]::FromSeconds(30))) {
            Write-Error "IE response timed out."; ExitFailure
        }
        Start-Sleep -m 100
    }
    until ( $ie.ReadyState -eq 4 -and
            $ie.Document.readyState -eq 'complete')
}

# Use this function to run JavaScript on a web page. Your $jsCommand can
# return a value which will be returned by this function unless $global
# switch is specified in which case $jsCommand will be executed in global
# scope and cannot return a value. If you received error 80020101 it means
# you need to fix your JavaScript code.
Function ExecJavaScript($ie, $jsCommand, [switch]$global)
{
    if (!$global) {
        $jsCommand = "document.body.setAttribute('PSResult', (function(){$jsCommand})());"
    }
    WaitForIE
    $document = $ie.document
    $window = $document.parentWindow
    $window.execScript($jsCommand, 'javascript') | Out-Null
    if (!$global) {
        return $document.body.getAttribute('PSResult')
    }
}

Function CheckJQueryExists
{
    $result = ExecJavaScript $ie 'return window.hasOwnProperty("$");'
    return ($result -eq $true)
}

$ie = New-Object -COM InternetExplorer.Application -Property @{
    Navigate = $url
    Visible = $true
}
do { Start-Sleep -m 100 } while ( $ie.ReadyState -ne 4 )

$jQueryExists = CheckJQueryExists $ie
echo "jQuery exists? $jQueryExists"

# make a jQuery call
ExecJavaScript $ie @'
    // this is JS code, remember to use semicolons
    var content = $('#home-content');
    return content.text();
'@

# Quit and dispose IE COM
$ie.Quit()
[System.Runtime.Interopservices.Marshal]::ReleaseComObject($ie) | out-null
Remove-Variable ie
