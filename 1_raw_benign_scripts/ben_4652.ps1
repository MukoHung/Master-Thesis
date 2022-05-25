param (
    [Parameter(Mandatory)]
    [string]
    $Module,
    [Parameter(Mandatory)]
    [string[]]
    $Functions
)

Describe "<Module> Module Tests" -Tag ('Structure') {

    Context "Module Setup" {

        It "has the root module $Module.psm1" -TestCases @{ Module = $Module } {
            "$PSScriptRoot\..\$Module.psm1" | Should -Exist
        }

        It "has a manifest file $Module.psd1" -TestCases @{ Module = $Module } {
            "$PSScriptRoot\..\$Module.psd1" | Should -Exist
            "$PSScriptRoot\..\$Module.psd1" | Should -FileContentMatch "$Module.psm1"
        }

        It "$PSScriptRoot folder has functions" -TestCases @{ Module = $Module } {
            "$PSScriptRoot\..\*.ps1" | Should -Exist
        }

        It "$Module is valid PowerShell code" -TestCases @{ Module = $Module } {
            $file = Get-Content -Path "$PSScriptRoot\..\$Module.psm1" `
                -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($file, [ref]$errors)
            $errors.Count | Should -Be 0
        }

    } # Context "Module Setup"

    Context "Test Function <_>" -Foreach $Functions {

        It "<_>.ps1 should exist" {
            "$PSScriptRoot\..\$_.ps1" | Should -Exist
        }

        It "<_>.ps1 function should have comment-based help" {
            "$PSScriptRoot\..\$_.ps1" | Should -FileContentMatch '<#'
            "$PSScriptRoot\..\$_.ps1" | Should -FileContentMatch '#>'
        }

        It "<_>.ps1 function should have a SYNOPSIS section in the comment-based help" {
            "$PSScriptRoot\..\$_.ps1" | Should -FileContentMatch '.SYNOPSIS'
        }

        It "<_>.ps1 function should have a DESCRIPTION section in the comment-based help" {
            "$PSScriptRoot\..\$_.ps1" | Should -FileContentMatch '.DESCRIPTION'
        }

        It "<_>.ps1 function should have a EXAMPLE section in the comment-based help" {
            "$PSScriptRoot\..\$_.ps1" | Should -FileContentMatch '.EXAMPLE'
        }

        It "<_>.ps1 function should be an advanced function" {
            "$PSScriptRoot\..\$_.ps1" | Should -FileContentMatch 'function'
            "$PSScriptRoot\..\$_.ps1" | Should -FileContentMatch '[CmdletBinding()]'
            "$PSScriptRoot\..\$_.ps1" | Should -FileContentMatch 'param'
        }

        It "<_>.ps1 is valid PowerShell code" {
            $file = Get-Content -Path "$PSScriptRoot\..\$_.ps1" `
                -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($file, [ref]$errors)
            $errors.Count | Should -Be 0
        }
    } # Context "Test Function <_>" -Foreach $Functions

    Context "Function <_> has tests" -Foreach $Functions {

        It "<_>.Tests.ps1 should exist" {
            "$PSScriptRoot\$_.Tests.ps1" | Should -Exist
        }
    } # Context "Function <_> has tests" -Foreach $Functions
}
