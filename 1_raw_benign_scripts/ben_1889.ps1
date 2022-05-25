$rdcmanName = "Azure VMs"
$outputFileName = Get-Location | Join-Path -ChildPath "AzureVMs.rdg"

$xml = [xml]'<?xml version="1.0" encoding="utf-8"?>
<RDCMan schemaVersion="1">
    <version>2.2</version>
    <file>
        <properties>
            <name>blog</name>
            <expanded>True</expanded>
            <comment />
            <logonCredentials inherit="FromParent" />
            <connectionSettings inherit="FromParent" />
            <gatewaySettings inherit="FromParent" />
            <remoteDesktop inherit="FromParent" />
            <localResources inherit="FromParent" />
            <securitySettings inherit="FromParent" />
            <displaySettings inherit="FromParent" />
        </properties>
        <group>
            <properties>
                <name>a group</name>
                <expanded>False</expanded>
                <comment />
                <logonCredentials inherit="FromParent" />
                <connectionSettings inherit="FromParent" />
                <gatewaySettings inherit="FromParent" />
                <remoteDesktop inherit="FromParent" />
                <localResources inherit="FromParent" />
                <securitySettings inherit="FromParent" />
                <displaySettings inherit="FromParent" />
            </properties>
            <server>
                <name>myservername</name>
                <displayName>my display name</displayName>
                <comment />
                <logonCredentials inherit="FromParent" />
                <connectionSettings inherit="None">
                    <connectToConsole>False</connectToConsole>
                    <startProgram />
                    <workingDir />
                    <port>12345</port>
                </connectionSettings>
                <gatewaySettings inherit="FromParent" />
                <remoteDesktop inherit="FromParent" />
                <localResources inherit="FromParent" />
                <securitySettings inherit="FromParent" />
                <displaySettings inherit="FromParent" />
            </server>
        </group>
    </file>
</RDCMan>'

$fileElement =$xml.RDCMan.file
$groupTemplateElement =$xml.RDCMan.file.group
$fileElement.properties.name = $rdcmanName

Get-AzureService | %{
    $service = $_
    $gotVmWithRdpEndpoint = $false

    $groupElement = $groupTemplateElement.Clone()
    $groupElement.properties.name = $service.ServiceName
    
    $serverTemplateElement = $groupElement.server
    Get-AzureVM -ServiceName $service.ServiceName | %{
        $vm = $_
        $rdpEndpoints = @($vm.VM.ConfigurationSets.InputEndpoints | ?{$_.LocalPort -eq 3389})
        if($rdpEndpoints.Length -gt 0){
            # got a Remote Desktop endpoint
            # add the server element
            $serverElement = $serverTemplateElement.Clone()
            $address = $vm.DNSName
            $serverElement.name = $vm.DNSName.TrimStart("http://").TrimEnd("/")
            $serverElement.displayName = $vm.Name

            $serverElement.connectionSettings.port = $rdpEndpoints[0].Port.ToString()
            $groupElement.AppendChild($serverElement) | out-null 
            $gotVmWithRdpEndpoint = $true
        }
    }

    if($gotVmWithRdpEndpoint){
        $groupElement.RemoveChild($serverTemplateElement) | out-null
        ($fileElement.AppendChild($groupElement)) | out-null
    }
}

$fileElement.RemoveChild($groupTemplateElement) | out-null


$xml.Save($outputFileName)
