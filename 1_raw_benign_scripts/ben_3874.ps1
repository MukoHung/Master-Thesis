function Invoke-InstallMenu {
    do {
        $choice = $host.ui.PromptForChoice(
            'Install menu',
            'Please choose what to install...',
            @(
                (New-Object System.Management.Automation.Host.ChoiceDescription "E&xit","Exit install menu")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&Windows","Set up Windows")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&System","Install base system")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&Basic","Install basic tools")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&Programming","Install programming tools")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&Document","Install document tools")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&Media","Install media tools")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&Learning","Install learning tools")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&Other","Install other tools")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&All","Install everything")
            ),
            0)
        
        switch ($choice) {
            0 { Write-Host 'Exitting install menu...' }
            1 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task SetupWindows }
            2 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task InstallSystem }
            3 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task InstallBasicTools }
            4 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task InstallProgrammingTools }
            5 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task InstallDocumentTools }
            6 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task InstallMediaTools }
            7 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task InstallLearningTools }
            8 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task InstallOtherTools }
            9 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task InstallEverything }
            default { throw "Unsupported menu choice: ${choice}"}
        }

    } until ($choice -eq 0)
}
