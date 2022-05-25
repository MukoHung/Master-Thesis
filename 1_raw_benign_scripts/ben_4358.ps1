BeforeAll {
    Set-Location $PSScriptRoot
}

Describe "Tests Manifest Version" {
    It "Checks 4-level version" {

        $temp = "$(New-TemporaryFile).psd1"
        Copy-Item .\test.psd1 $temp

        ..\Update-ManifestVersion.ps1 -ManifestPath $temp -Major 9 -Minor 8 -Build 7 -Revision 6

        $manifest = Test-ModuleManifest -Path $temp -Verbose:$false
        $manifest.Version | Should -Be ([Version]"9.8.7.6")
    }

    It "Checks 3-level version" {

        $temp = "$(New-TemporaryFile).psd1"
        Copy-Item .\test.psd1 $temp

        ..\Update-ManifestVersion.ps1 -ManifestPath $temp -Major 9 -Minor 8 -Build 7

        $manifest = Test-ModuleManifest -Path $temp -Verbose:$false
        $manifest.Version | Should -Be ([Version]"9.8.7")
    }

    It "Checks 2-level version" {

        $temp = "$(New-TemporaryFile).psd1"
        Copy-Item .\test.psd1 $temp
        Update-ModuleManifest -Path $temp -ModuleVersion 9.8

        ..\Update-ManifestVersion.ps1 -ManifestPath $temp -Major 9 -Minor 8

        $manifest = Test-ModuleManifest -Path $temp -Verbose:$false
        $manifest.Version | Should -Be ([Version]"9.8")
    }

    It "Sets only revision" {

        $temp = "$(New-TemporaryFile).psd1"
        Copy-Item .\test.psd1 $temp

        ..\Update-ManifestVersion.ps1 -ManifestPath $temp -Revision 99

        $manifest = Test-ModuleManifest -Path $temp -Verbose:$false
        $manifest.Version | Should -Be ([Version]"0.1.0.99")
    }

    # most typical case to set build during build
    It "Sets only build" {

        $temp = "$(New-TemporaryFile).psd1"
        Copy-Item .\test.psd1 $temp

        ..\Update-ManifestVersion.ps1 -ManifestPath $temp -Build 99

        $manifest = Test-ModuleManifest -Path $temp -Verbose:$false
        $manifest.Version | Should -Be ([Version]"0.1.99")
    }

    It "Sets the SHA build" {

        $temp = "$(New-TemporaryFile).psd1"
        Copy-Item .\test.psd1 $temp

        ..\Update-ManifestVersion.ps1 -ManifestPath $temp -CommitSHA 75382ad59e8ec94b8f7b49be0961e3293bf8cb06

        $manifest = Test-ModuleManifest -Path $temp -Verbose:$false
        $manifest.PrivateData.CommitSHA | Should -Be 75382ad59e8ec94b8f7b49be0961e3293bf8cb06
    }

    It "Sets the Prerelease" {

        $temp = "$(New-TemporaryFile).psd1"
        Copy-Item .\test.psd1 $temp

        ..\Update-ManifestVersion.ps1 -ManifestPath $temp -Prerelease "alpha1"

        $manifest = Test-ModuleManifest -Path $temp -Verbose:$false
        $manifest.PrivateData.PSData.Prerelease | Should -Be 'alpha1'
    }

    It "Sets GitHub just Version" {

        $temp = "$(New-TemporaryFile).psd1"
        Copy-Item .\test.psd1 $temp

        ..\Update-ManifestVersion.ps1 -ManifestPath $temp -GitHubRef 'refs/head/release/v1.2.3'

        $manifest = Test-ModuleManifest -Path $temp -Verbose:$false
        $manifest.Version | Should -Be ([Version]"1.2.3")
    }
    It "Sets GitHub just Version and prerelease" {

        $temp = "$(New-TemporaryFile).psd1"
        Copy-Item .\test.psd1 $temp

        ..\Update-ManifestVersion.ps1 -ManifestPath $temp -GitHubRef 'refs/head/release/v1.2.3-alpha1'

        $manifest = Test-ModuleManifest -Path $temp -Verbose:$false
        $manifest.Version | Should -Be ([Version]"1.2.3")
        $manifest.PrivateData.PSData.Prerelease | Should -Be 'alpha1'

        ..\Update-ManifestVersion.ps1 -ManifestPath $temp -GitHubRef 'refs/head/release/v1.2.4'
        $manifest = Test-ModuleManifest -Path $temp -Verbose:$false
        $manifest.Version | Should -Be ([Version]"1.2.4")
        Get-Member -Input $manifest.PrivateData.PSData -name Prerelease | Should -Be $null

    }
    It "Sets GitHub just Version and prerelease with dash and build" {

        $temp = "$(New-TemporaryFile).psd1"
        Copy-Item .\test.psd1 $temp

        ..\Update-ManifestVersion.ps1 -ManifestPath $temp -GitHubRef 'refs/head/release/v1.2.3-alpha1+test123'

        $manifest = Test-ModuleManifest -Path $temp -Verbose:$false
        $manifest.Version | Should -Be ([Version]"1.2.3")
        $manifest.PrivateData.PSData.Prerelease | Should -Be 'alpha1'
    }
    It "Sets GitHub invalid" {

        $temp = "$(New-TemporaryFile).psd1"
        Copy-Item .\test.psd1 $temp

        { ..\Update-ManifestVersion.ps1 -ManifestPath $temp -GitHubRef 'refs/head/release/vabced-alpha1' } | Should -Throw
        { ..\Update-ManifestVersion.ps1 -ManifestPath $temp -GitHubRef 'refs/head/release/v1.2.3-alpha1-test' } | Should -Throw
    }
}