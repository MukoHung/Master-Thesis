# 
# File: Import-TestXml.ps1
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

trap {
    Write-Error ($Error[0] | Out-String)
    exit -1
}

Write-Verbose ('ResultName          : {0}' -f $ResultName)
Write-Verbose ('PropertyTree        : {0}' -f $PropertyTree)
Write-Verbose ('Serialization       : {0}' -f $Serialization)

function Assert {
    param ([scriptblock]$Predicate)
    if (!(& $Predicate)) {
        throw """$Predicate"" is not satisfied."
    }
}

switch ($PsCmdlet.ParameterSetName) {
    'PropertyTree' { 
        $dom = [xml](gc $ResultName)
        Assert { "C++ から書き換え！" -eq $dom.root.str }
        Assert { 3 -eq $dom.root.values.value.Length }
        Assert { 1 -eq [int]$dom.root.values.value[0] }
        Assert { 2 -eq [int]$dom.root.values.value[1] }
        Assert { 3 -eq [int]$dom.root.values.value[2] }
    }
    'Serialization' { 
        $here = Split-Path $MyInvocation.MyCommand.Path
        Add-Type ([System.IO.File]::ReadAllText([System.IO.Path]::Combine($here, "Person.cs"))) -ReferencedAssemblies System.Xml
        [Person]$person = $null
        try {
            $sr = New-Object System.IO.StreamReader $ResultName
            $serializer = New-Object System.Xml.Serialization.XmlSerializer ([Person])
            $person = $serializer.Deserialize($sr)
        } finally {
            if ($null -ne $sr) {
                $sr.Dispose()
            }
        }
        Assert { 16 -eq $person.Age }
        Assert { "泉 新一" -eq $person.Name }
        Assert { 2 -eq $person.Arms.item.Length }
        Assert { "ミギー" -eq $person.Arms.item[0].Name }
        Assert { "(null)" -eq $person.Arms.item[1].Name }
    }
    default {
        throw "We shouldn't get here."
    }
}

