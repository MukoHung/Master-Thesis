param(
    [switch] $Verbose,
    [switch] $Debug
)

if ($Debug) {
    Describe 'rust' {
        It 'code formatting' {
            Invoke-Expression "cargo +stable fmt --all -- --check 2>&1 | Out-Null"
            $LASTEXITCODE | Should -be 0 # please, run `cargo +stable fmt`
        }

        It 'tests in debug profile' {
            Invoke-Expression "cargo +stable test --manifest-path ../Cargo.toml --quiet"
            $LASTEXITCODE | Should -be 0
        }

        It 'tests in release profile' {
            Invoke-Expression "cargo +stable test --manifest-path ../Cargo.toml --release --quiet"
            $LASTEXITCODE | Should -be 0
        }
    }

    Describe 'all tests for picky (debug)' {
        Context 'Mongodb without save certificates on backend'{
            & ./Picky.Tests.ps1 -UseMongo -Debug -Verbose:$Verbose
        }
        Context 'Mongodb with save certificates on backend'{
            & ./Picky.Tests.ps1 -UseMongo -SavePickyCertificates -Debug -Verbose:$Verbose
        }
        Context 'Memory without save certificates on backend'{
            & ./Picky.Tests.ps1 -UseMemory -Debug -Verbose:$Verbose
        }
        Context 'Memory with save certificates on backend'{
            & ./Picky.Tests.ps1 -UseMemory -SavePickyCertificates -Debug -Verbose:$Verbose
        }
        Context 'File without save certificates on backend'{
            & ./Picky.Tests.ps1 -UseFile -Debug -Verbose:$Verbose
        }
        Context 'File with save certificates on backend'{
            & ./Picky.Tests.ps1 -UseFile -SavePickyCertificates -Debug -Verbose:$Verbose
        }
    }
} else {
    Describe 'all tests for picky' {
        Context 'Mongodb without save certificates on backend'{
            & ./Picky.Tests.ps1 -UseMongo -Verbose:$Verbose
        }
        Context 'Mongodb with save certificates on backend'{
            & ./Picky.Tests.ps1 -UseMongo -SavePickyCertificates -Verbose:$Verbose
        }
        Context 'Memory without save certificates on backend'{
            & ./Picky.Tests.ps1 -UseMemory -Verbose:$Verbose
        }
        Context 'Memory with save certificates on backend'{
            & ./Picky.Tests.ps1 -UseMemory -SavePickyCertificates -Verbose:$Verbose
        }
        Context 'File without save certificates on backend'{
            & ./Picky.Tests.ps1 -UseFile -Verbose:$Verbose
        }
        Context 'File with save certificates on backend'{
            & ./Picky.Tests.ps1 -UseFile -SavePickyCertificates -Verbose:$Verbose
        }
    }
}
