# 
# File: Export-TestXml.ps1
# 
# Author: Akira Sugiura (urasandesu@gmail.com)
# 
# 
# Copyright (c) 2015 Akira Sugiura
#  
#  This software is MIT License.
#  
#  Permission is hereby granted, free of charge, to any person obtaining a copy
#  of this software and associated documentation files (the "Software"), to deal
#  in the Software without restriction, including without limitation the rights
#  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
#  copies of the Software, and to permit persons to whom the Software is
#  furnished to do so, subject to the following conditions:
#  
#  The above copyright notice and this permission notice shall be included in
#  all copies or substantial portions of the Software.
#  
#  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
#  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
#  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
#  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
#  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
#  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
#  THE SOFTWARE.
#

[CmdletBinding()]
param (
    [string]
    $ResultName, 

    [Parameter(ParameterSetName = 'PropertyTree')]
    [switch]
    $PropertyTree, 

    [Parameter(ParameterSetName = 'Serialization')]
    [switch]
    $Serialization
)

Write-Verbose ('ResultName          : {0}' -f $ResultName)
Write-Verbose ('PropertyTree        : {0}' -f $PropertyTree)
Write-Verbose ('Serialization       : {0}' -f $Serialization)

switch ($PsCmdlet.ParameterSetName) {
    'PropertyTree' { 
        $dom = [xml]@"
<?xml version="1.0" encoding="utf-8"?>
<root>
  <str>PowerShell から書き換え！</str>
  <values>
    <value>1</value>
    <value>2</value>
    <value>3</value>
  </values>
</root>
"@
        $dom.Save($ResultName)
    }
    'Serialization' { 
        $here = Split-Path $MyInvocation.MyCommand.Path
        Add-Type ([System.IO.File]::ReadAllText([System.IO.Path]::Combine($here, "Person.cs"))) -ReferencedAssemblies System.Xml
        $person = New-Object Person
        $person.class_id = 0
        $person.Age = 16
        $person.Name = "泉 新一"
        $person.Arms = New-Object Arms
        $person.Arms.class_id = 1
        $person.Arms.count = 2
        $person.Arms.item = [Arm[]]@((New-Object Arm), (New-Object Arm))
        $person.Arms.item[0].class_id = 2
        $person.Arms.item[0].Name = "ミギー"
        $person.Arms.item[1].class_id = 2
        $person.Arms.item[1].Name = "(null)"
        try {
            $sw = New-Object System.IO.StreamWriter $ResultName, $false, ([System.Text.Encoding]::UTF8)
            $ns = New-Object System.Xml.Serialization.XmlSerializerNamespaces
            $ns.Add("", "")
            $serializer = New-Object System.Xml.Serialization.XmlSerializer ([Person])
            $serializer.Serialize($sw, $person, $ns)
        } finally {
            if ($null -ne $sw) {
                $sw.Dispose()
            }
        }
    }
    default {
        throw "We shouldn't get here."
    }
}


