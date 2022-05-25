# 
# File: Export-TestJson.ps1
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

Write-Verbose ('ResultName          : {0}' -f $ResultName)
Write-Verbose ('PropertyTree        : {0}' -f $PropertyTree)

switch ($PsCmdlet.ParameterSetName) {
    'PropertyTree' { 
        $json = 
            New-Object psobject | 
                Add-Member NoteProperty "root" (
                    New-Object psobject | 
                        Add-Member NoteProperty "str" "PowerShell から書き換え！" -PassThru | 
                        Add-Member NoteProperty "values" @(
                            (New-Object psobject | Add-Member NoteProperty "value" "1" -PassThru), 
                            (New-Object psobject | Add-Member NoteProperty "value" "2" -PassThru), 
                            (New-Object psobject | Add-Member NoteProperty "value" "3" -PassThru)
                        ) -PassThru
                ) -PassThru
        ConvertTo-Json $json -Depth 3 | Out-File $ResultName -Encoding utf8
    }
    default {
        throw "We shouldn't get here."
    }
}


