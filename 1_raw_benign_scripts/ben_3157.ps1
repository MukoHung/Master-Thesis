Import-Module "$(Split-Path -Parent $MyInvocation.MyCommand.Path)/../PSMerakiAPI/PSMerakiAPI.psm1" -Prefix "PSMAPI"
$ModuleName = "PSMerakiAPI"

$root = "$(Split-Path -Parent $MyInvocation.MyCommand.Path)/../$ModuleName"

$PSDefaultParameterValues = @{
    "It:TestCases" = @{ root = $root; ModuleName = $ModuleName}
}

Describe 'Module' {
    Context 'Module Setup' {
        It "Has the root module $ModuleName.psm1" {
            "$root/$ModuleName.psm1" | Should -Exist
        }

        It "has the a manifest file of $ModuleName.psd1" {
            "$root\$ModuleName.psd1" | Should -Exist
        }

        It "$ModuleName Public folder has functions" {
            "$root\Public\*.ps1" | Should -Exist
        }

        It "$ModuleName Private folder has functions" {
            "$root\Private\*.ps1" | Should -Exist
        }

        It "$module is valid PowerShell code" {
            $psFile = Get-Content -Path "$root\$ModuleName.psm1" -ErrorAction Stop
            $errors = $null
            $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
            $errors.Count | Should -Be 0
        }
    } # Context 'Module Setup'

    $functions = Get-ChildItem "$root\Public\*.ps1" | Select-Object -ExpandProperty BaseName

    foreach ($function in $functions) {
        $PSDefaultParameterValues = @{
            "It:TestCases" = @{ root = $root; ModuleName = $ModuleName; function = $function}
        }

        Context "Test Function $function" {

            It "$function.ps1 should exist" {
                "$root\Public\$function.ps1" | Should -Exist
            }

            It "$function.ps1 should have help block" {
                "$root\Public\$function.ps1" | Should -FileContentMatch '<#'
                "$root\Public\$function.ps1" | Should -FileContentMatch '#>'
            }

            It "$function.ps1 should have a SYNOPSIS section in the help block" {
                "$root\Public\$function.ps1" | Should -FileContentMatch '.SYNOPSIS'
            }

            It "$function.ps1 should have a DESCRIPTION section in the help block" {
                "$root\Public\$function.ps1" | Should -FileContentMatch '.DESCRIPTION'
            }

            It "$function.ps1 should have a EXAMPLE section in the help block" {
                "$root\Public\$function.ps1" | Should -FileContentMatch '.EXAMPLE'
            }

            It "$function.ps1 should have a NOTES section in the help block" {
                "$root\Public\$function.ps1" | Should -FileContentMatch '.NOTES'
            }

            It "$function.ps1 should be an advanced function" {
                "$root\Public\$function.ps1" | Should -FileContentMatch 'function'
                "$root\Public\$function.ps1" | Should -FileContentMatch 'cmdletbinding'
                "$root\Public\$function.ps1" | Should -FileContentMatch 'param'
            }

            It "$function.ps1 should contain Write-Verbose blocks" {
                "$root\Public\$function.ps1" | Should -FileContentMatch 'Write-Verbose'
            }

            It "$function.ps1 is valid PowerShell code" {
                $psFile = Get-Content -Path "$root\Public\$function.ps1" -ErrorAction Stop
                $errors = $null
                $null = [System.Management.Automation.PSParser]::Tokenize($psFile, [ref]$errors)
                $errors.Count | Should -Be 0
            }

        } # Context "Test Function $function"

        Context "$function has supporting files" {
            It "UnitTests\function_$function.Tests.ps1 should exist" {
                "$root\..\UnitTests\function_$function.Tests.ps1" | Should -Exist
            }
            It "Docs\$function.md should exist" {
                "$root\..\Docs\$function.md" | Should -Exist
            }
        }

    } # foreach ($function in $functions)
}
