function Invoke-TestMenu {
    do {
        $choice = $host.ui.PromptForChoice(
            'Test menu',
            'Please choose the test...',
            @(
                (New-Object System.Management.Automation.Host.ChoiceDescription "E&xit","Exit test menu")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&Windows","Test Windows")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&System","Test system")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&Basic","Test basic tools")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&Programming","Test programming tools")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&Document","Test document tools")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&Media","Test media tools")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&Learning","Test learning tools")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&Other","Test other miscelaneous tools")
                (New-Object System.Management.Automation.Host.ChoiceDescription "&All","Test everything")
            ),
            0)
        
        switch ($choice) {
            0 { Write-Host 'Exitting test menu...' }
            1 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task TestWindows }
            2 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task TestSystem }
            3 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task TestBasicTools }
            4 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task TestProgrammingTools }
            5 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task TestDocumentTools }
            6 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task TestMediaTools }
            7 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task TestLearningTools }
            8 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task TestOtherTools }
            9 { Invoke-PSake "$($psake.build_script_dir)\build.psake.ps1" -Task TestEverything }
            default { throw "Unsupported menu choice: ${choice}"}
        }

    } until ($choice -eq 0)
}
