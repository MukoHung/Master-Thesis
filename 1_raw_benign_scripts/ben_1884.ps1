# 
# File: Import-TestJson.ps1
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
    $PropertyTree
)

trap {
    Write-Error ($Error[0] | Out-String)
    exit -1
}

Write-Verbose ('ResultName          : {0}' -f $ResultName)
Write-Verbose ('PropertyTree        : {0}' -f $PropertyTree)

function Assert {
    param ([scriptblock]$Predicate)
    if (!(& $Predicate)) {
        throw """$Predicate"" is not satisfied."
    }
}

switch ($PsCmdlet.ParameterSetName) {
    'PropertyTree' { 
        $json = gc $ResultName | ConvertFrom-Json
        Assert { "C++ から書き換え！" -eq $json.root.str }
        Assert { 3 -eq $json.root.values.value.Length }
        Assert { 1 -eq [int]$json.root.values.value[0] }
        Assert { 2 -eq [int]$json.root.values.value[1] }
        Assert { 3 -eq [int]$json.root.values.value[2] }
    }
    default {
        throw "We shouldn't get here."
    }
}

