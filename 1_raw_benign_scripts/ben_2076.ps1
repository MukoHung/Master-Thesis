<# 
$Params = @{
    Script = "$PSScriptRoot\Tests\sthPipelineCommand.Tests.ps1"
    CodeCoverage = @{Path = "$PSScriptRoot\sthPipelineCommand.ps1"; Function = 'Get-sthPipelineCommand'}

}

Invoke-Pester @Params

$Params = @{
    Script = "$PSScriptRoot\Tests\sthPipelineParameter.Tests.ps1"
    CodeCoverage = @{Path = "$PSScriptRoot\sthPipelineParameter.ps1"; Function = 'Get-sthPipelineParameter'}
    # Tag = 'TheTag'
}

Invoke-Pester @Params
 #>

 $Params = @{
    # Script = "$PSScriptRoot\Tests\sthPipelineCommand.Tests.ps1", "$PSScriptRoot\Tests\sthPipelineParameter.Tests.ps1"
    Script = "$PSScriptRoot\Tests\sthTest.tests.ps1"
    # Script = "$PSScriptRoot\Tests\sthPipelineCommand.Tests.ps1"
    # Script = "$PSScriptRoot\Tests\sthPipelineParameter.Tests.ps1"
    # Script = "$PSScriptRoot\Tests\sthPipelineTools.Tests.ps1"
    # CodeCoverage = @{Path = "$PSScriptRoot\sthPipelineCommand.ps1"; Function = 'Get-sthPipelineParameter'}, @{Path = "$PSScriptRoot\sthPipelineParameter.ps1"; Function = 'Get-sthPipelineParameter'}
    # CodeCoverage = @{Path = "$PSScriptRoot\sthPipelineCommand.ps1", "$PSScriptRoot\sthPipelineParameter.ps1"; Function = 'Get-sthPipelineCommand','Get-sthPipelineParameter'}
    CodeCoverage = "$PSScriptRoot\sthTest.ps1"
    # Tag = 'TheTag'
}

Invoke-Pester @Params

# Invoke-Pester -Script "$PSScriptRoot\Tests\sthPipelineCommand.Tests.ps1", "$PSScriptRoot\Tests\sthPipelineParameter.Tests.ps1"