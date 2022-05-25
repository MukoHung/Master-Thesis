#requires -version 5
<#
.SYNOPSIS
  Initial script for launching SIPR Administration Scripts.
.DESCRIPTION
  This script will load all global functions and variables to be used by the rest of the forms.
.PARAMETER NOSOverride
    Switch to launch the NOS version of the forms which allows selecting multiple domains and bases.
.PARAMETER Beta
    Switch to launch the beta version of the scripts. Changes the file path for a couple things.
.INPUTS
  None
.OUTPUTS
  Log file stored in %LocalAppData%\Admin-Scripts.log
.NOTES
  Version:        1.0
  Author:         Michael Calabrese
  Creation Date:  1/18/2022
  Purpose/Change: Initial script development
  ToDo List: 
    - Update the Update-Scripts function
  
.EXAMPLE
  Shortcut for base level admin
  C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Hidden -File C:\Administration_Scripts\Admin-Scripts.ps1

.EXAMPLE
  Shortcut for NOS/COS admin running from a DC
  C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -WindowStyle Hidden -File C:\Administration_Scripts\Admin-Scripts.ps1 NOSOverride

.EXAMPLE
  Shortcut for base level admin beta testing, note that the window is not hidden in beta
  C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -File C:\Beta_Scripts\Admin-Scripts.ps1 Beta
#>

Param (
    [Switch]$NOSOverride,
    [Switch]$Beta
)

#Load Assemblies, only required because I wanted to make the resources globally available. 
#PS Pro Tools makes a resource file for each form and that's overkill for this.
[void][System.Reflection.Assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
[void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')

#region Variables
$Global:credentials = [System.Management.Automation.PSCredential]::Empty #This is to allow for credential use in the form
$Global:resourcesFolder = Join-Path $PSScriptRoot 'Resources'
$Global:launchersFolder = Join-Path $PSScriptRoot 'Launchers'
$Global:createFormsFolder = Join-Path $PSScriptRoot 'CreateForms'
$Global:editFormsFolder = Join-Path $PSScriptRoot 'EditForms'
$Global:otherFormsFolder = Join-Path $PSScriptRoot 'OtherForms'
$Global:resources = . (Join-Path $resourcesFolder 'AdminForms.resources.ps1')

#region Functions
Function Global:Add-UserToGroups {
    #This function will loop through a set of groups and add a user object to them
    Param(
        [Parameter(Mandatory)]
        [Array]$selectedgroups,
        
        [Parameter(Mandatory)]
        [Microsoft.ActiveDirectory.Management.ADAccount]$User
    )

    try {
        $selectedgroups | ForEach-Object {
             if ($credentials -eq [System.Management.Automation.PSCredential]::Empty) {
                 Add-ADGroupMember -Identity $_.Name -Members $User.samAccountName -Server $DC
             } else {
                 Add-ADGroupMember -Identity $_.Name -Members $User.samAccountName -Server $DC -Credential $credentials
             }
         }

        #If adding groups successful, show success message to user
        [System.Windows.Forms.MessageBox]::Show("Successfully added account to groups:" + [System.Environment]::NewLine + ($selectedgroups.Text -join [System.Environment]::NewLine),'Group Add Successfull')
     } catch {
         #If it failed show the error to the user
         [System.Windows.Forms.MessageBox]::Show('Adding groups to ' + $User.CN + 'failed with the following error: ' + $_.exception.message,"Error Occurred!")
         Write-Log -Message ($_ | Out-String) -Type Error -LogName CreateUserForm
     }
}

Function Global:Add-Node {
    ##Requires Get-NextLevel
    #Used to populate TreeNodes in a TreeView.
    #When Node has children, adds a blank Node to save loading time.
    Param(
        [Parameter(Mandatory)]
        $parentNode,
        
        [Parameter(Mandatory)]
        [String]$nodeName,
        
        [String]$nodeTag,
        
        [Parameter(Mandatory)][String]$nodeText,
        
        [Switch]$hasChildren
    )

    $newNode = New-Object System.Windows.Forms.TreeNode
    $newNode.Tag = $nodeTag
    $newNode.Name = $nodeName 
    $newNode.Text = $nodeText

    if($hasChildren) {
        [Void]$newNode.Nodes.Add('')
    }
    [Void]$parentNode.Nodes.Add($newNode)
    $newNode
}

Function Global:Generate-Password {
    #Simple function to generate a compliant password using the builtin System.Web assembly.
    Add-Type -AssemblyName System.Web
    $PassComplexCheck = $false
    do {
        $newPassword=[System.Web.Security.Membership]::GeneratePassword(16,1)
        if ( ($newPassword -cmatch "[A-Z\p{Lu}\s]") `
            -and ($newPassword -cmatch "[a-z\p{Ll}\s]") `
            -and ($newPassword -match "[\d]") `
            -and ($newPassword -match "[^\w]") ) {
            $PassComplexCheck=$True
        }
    } while ($PassComplexCheck -eq $false)
    return $newPassword
}

Function Global:Get-BaseNames {
    #Grabs the OUs under the Bases OU and gets City (GeoCode), businessCategory (Units), and DistinguishedName.
    try {
        if($credentials -eq [System.Management.Automation.PSCredential]::Empty) {
            $baseNames = Get-ADOrganizationalUnit -Filter * -SearchBase "OU=Bases,$($Domain.DistinguishedName)" -SearchScope OneLevel -Properties City,businessCategory,DistinguishedName -Server $DC | Select-Object Name,City,businessCategory,DistinguishedName
        } else {
            $baseNames = Get-ADOrganizationalUnit -Filter * -SearchBase "OU=Bases,$($Domain.DistinguishedName)" -SearchScope OneLevel -Properties City,businessCategory,DistinguishedName -Server $DC -Credential $credentials | Select-Object Name,City,businessCategory,DistinguishedName
        }
    } catch {
        $baseNames = $null
    }
    return $baseNames
}

Function Global:Get-DomainInfo {
    #Populates the global Domain variable depending on the server passed to it.
    Param(
        [Parameter(Mandatory)]
        [String]$Server
    )

    try {
        if($credentials -eq [System.Management.Automation.PSCredential]::Empty) {
            $global:Domain = Get-ADDomain -Server $Server
        } else {
            $global:Domain = Get-ADDomain -Server $Server -Credential $credentials
        } 
    } catch {
        $global:Domain=$null
    }
}

Function Global:Get-ForestInfo {
    #Populates the global Forest variable depending on the server passed to it.
    Param(
        [Parameter(Mandatory)]
        [String]$Server
    )

    try {
        if($credentials -eq [System.Management.Automation.PSCredential]::Empty) {
            $global:Forest = Get-ADForest -Server $Server
        } else {
            $global:Forest = Get-ADForest -Server $Server -Credential $credentials
        }
    } catch {
        $global:Forest=$null
    }
}

Function Global:Get-MAJCOMList {
    #Returns a list of MAJCOMS from the Bases OU businessCategory attribute.
    #Created to work with the NIPR format.
    try {
        if($credentials -eq [System.Management.Automation.PSCredential]::Empty) {
            $MAJCOMList=Get-ADOrganizationalUnit "OU=Bases,$($Domain.DistinguishedName)" -Properties businessCategory -Server $DC | Select-Object -ExpandProperty businessCategory | % {
                [pscustomobject]@{Acronym=$_.Split(' ')[0];LongName=($_ -Split' - ')[1]}
            }
        } else{
            $MAJCOMList=Get-ADOrganizationalUnit "OU=Bases,$($Domain.DistinguishedName)" -Properties businessCategory -Server $DC -Credential $credentials | Select-Object -ExpandProperty businessCategory | % {
                [pscustomobject]@{Acronym=$_.Split(' ')[0];LongName=($_ -Split' - ')[1]}
            }
        }
    } catch {
        $MAJCOMList = $null
    }
    return $MAJCOMList
}

Function Global:Get-NextLevel {
    ##Requires Add-Node
    #Used to load the children of TreeNodes in a TreeView.
    #There's a lot in there I'm not using. Not sure if this is entirely needed in this script but it's nice for other things.
    Param(
        [Parameter(Mandatory)]
        $parentNode,
        
        [ValidateSet('Users','Computers')]
        [String]$showObjects
    )

    $parentNode.Nodes.Clear()
    if($showObjects -eq 'Users') {
        try {
            if($credentials -eq [System.Management.Automation.PSCredential]::Empty) {
                $Users=Get-ADUser -Filter * -SearchBase $parentNode.Name -SearchScope OneLevel -Server $DC
            } else {
                $Users=Get-ADUser -Filter * -SearchBase $parentNode.Name -SearchScope OneLevel -Server $DC -Credential $credentials
            }
            if($Users) {
                $Users | % {
                    Add-Node -parentNode $parentNode -nodeName $_.DistinguishedName -nodeText $_.Name -nodeTag 'User' | Out-Null
                }
            }
        }
        catch {
            $Users = $null
        }
    }

    if($showObjects -eq 'Computers') {
        try {
            if($credentials -eq [System.Management.Automation.PSCredential]::Empty) {
                $Computers=Get-ADComputer -Filter * -SearchBase $parentNode.Name -SearchScope OneLevel -Server $DC
            } else {
                $Computers=Get-ADComputer -Filter * -SearchBase $parentNode.Name -SearchScope OneLevel -Server $DC -Credential $credentials
            }
        }
        catch {
            $Computers = $null
        }
        if($Computers) {
            $Computers | % {
                Add-Node -parentNode $parentNode -nodeName $_.DistinguishedName -nodeText $_.Name -nodeTag 'Computer' | Out-Null
            }
        }
    }
    
    try {
        if($credentials -eq [System.Management.Automation.PSCredential]::Empty) {
            $OUs=Get-ADOrganizationalUnit -Filter * -SearchBase $parentNode.Name -SearchScope OneLevel -Server $DC
        } else {
            $OUs=Get-ADOrganizationalUnit -Filter * -SearchBase $parentNode.Name -SearchScope OneLevel -Server $DC -Credential $credentials
        }
    }
    catch {
        $OUs = $null
    }
    if($OUs) {
        $OUs | % {
            try {
                if($credentials -eq [System.Management.Automation.PSCredential]::Empty) {
                    $childOus = Get-ADOrganizationalUnit -Filter * -SearchBase $_.DistinguishedName -SearchScope OneLevel -Server $DC
                } else {
                    $childOus = Get-ADOrganizationalUnit -Filter * -SearchBase $_.DistinguishedName -SearchScope OneLevel -Server $DC -Credential $credentials
                }
            }
            catch {
                $childOus = $null
            }

            if($showObjects -eq 'Users') {
                try {
                    if($credentials -eq [System.Management.Automation.PSCredential]::Empty) {
                        $childUsers = Get-ADUser -Filter * -SearchBase $_.DistinguishedName -SearchScope OneLevel -Server $DC
                    } else {
                        Get-ADUser -Filter * -SearchBase $_.DistinguishedName -SearchScope OneLevel -Server $DC -Credential $credentials
                    }
                }
                catch {
                    $childUsers = $null
                }
                
                if($childOus -or $childUsers) {
                    Add-Node -parentNode $parentNode -nodeName $_.DistinguishedName -nodeText $_.Name -hasChildren | Out-Null
                } else {
                    Add-Node -parentNode $parentNode -nodeName $_.DistinguishedName -nodeText $_.Name | Out-Null
                }
            }

            elseif($showObjects -eq 'Computers') {
                try {
                    if($credentials -eq [System.Management.Automation.PSCredential]::Empty) {
                        $childComputers = Get-ADComputer -Filter * -SearchBase $_.DistinguishedName -SearchScope OneLevel -Server $DC
                    } else {
                        Get-ADComputer -Filter * -SearchBase $_.DistinguishedName -SearchScope OneLevel -Server $DC -Credential $credentials
                    }
                } catch {
                    $childComputers = $null
                }

                if($childOus -or $childComputers) {
                    Add-Node -parentNode $parentNode -nodeName $_.DistinguishedName -nodeText $_.Name -hasChildren | Out-Null
                } else {
                    Add-Node -parentNode $parentNode -nodeName $_.DistinguishedName -nodeText $_.Name | Out-Null
                }
            } else {
                if($childOus) {
                    Add-Node -parentNode $parentNode -nodeName $_.DistinguishedName -nodeText $_.Name -hasChildren | Out-Null
                } else {
                    Add-Node -parentNode $parentNode -nodeName $_.DistinguishedName -nodeText $_.Name | Out-Null
                }
            }
        }
    }
}

Function Global:Locate-DomainController {
    #Populates the global DC variable depending on the server passed to it.
    Param(
        [Parameter(Mandatory)]
        [String]$Server
    )

    try {
        if($credentials -eq [System.Management.Automation.PSCredential]::Empty) {
            $global:DC = (Get-ADDomainController -Server $Server).HostName
        } else {
            $global:DC = (Get-ADDomainController -Server $Server -Credential $credentials).HostName
        } 
    } catch {
        $global:DC = $null
    }
}

Function Global:Update-AdminScripts {
    #Mirrors any file that matches the ScriptName param.
    #Useful for updating both the Form.ps1 and the Form.designer.ps1 file along with any other misc files.
    Param(       
        [Switch]$Beta
    )

    if($Beta){
        Write-Host "Syncing Form: $ScriptName with the domain master copy"
        robocopy.exe "$env:LOGONSERVER\netlogon\Administration_Scripts\BetaAdmin_Scripts" "$env:SystemDrive\BetaAdmin_Scripts" /MIR | Out-Null
    } else {
        robocopy.exe "$env:LOGONSERVER\netlogon\Administration_Scripts\Production_Scripts" "$env:SystemDrive\Administration_Scripts" | Out-Null
    }
}

Function Global:Show-BetterMessageBox {
    #Shows a messagebox that sizes better than the builtin messagebox.
    #Useful for showing large amounts of information to the user.
    Param(
        [Parameter(Mandatory)]
        [String]$Message,
        
        [String]$Title,
        
        [ValidateSet('OkOnly','YesNo')]
        [String]$Buttons
    )

    [void][System.Reflection.Assembly]::Load('System.Drawing, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b03f5f7f11d50a3a')
    [void][System.Reflection.Assembly]::Load('System.Windows.Forms, Version=4.0.0.0, Culture=neutral, PublicKeyToken=b77a5c561934e089')
    $Form1 = New-Object -TypeName System.Windows.Forms.Form
    [System.Windows.Forms.Label]$label1 = $null
    [System.Windows.Forms.FlowLayoutPanel]$flowLayoutPanel1 = $null
    [System.Windows.Forms.Button]$okButton = $null
    [System.Windows.Forms.Button]$yesButton = $null
    [System.Windows.Forms.Button]$noButton = $null
    [System.Windows.Forms.Button]$button1 = $null
    $label1 = (New-Object -TypeName System.Windows.Forms.Label)
    $flowLayoutPanel1 = (New-Object -TypeName System.Windows.Forms.FlowLayoutPanel)
    $okButton = (New-Object -TypeName System.Windows.Forms.Button)
    $yesButton = (New-Object -TypeName System.Windows.Forms.Button)
    $noButton = (New-Object -TypeName System.Windows.Forms.Button)
    $flowLayoutPanel1.SuspendLayout()
    $Form1.SuspendLayout()
    #
    #label1
    #
    $label1.AutoSize = $true
    $flowLayoutPanel1.SetFlowBreak($label1,$true)
    $label1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]3,[System.Int32]0))
    $label1.Name = [System.String]'label1'
    $label1.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]51,[System.Int32]20))
    $label1.TabIndex = [System.Int32]0
    $label1.Text = $Message
    #
    #flowLayoutPanel1
    #
    $flowLayoutPanel1.AutoSize = $true
    $flowLayoutPanel1.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
    $flowLayoutPanel1.Controls.Add($label1)
    Switch($Buttons) {
        'OkOnly' {
            $flowLayoutPanel1.Controls.Add($okButton)
        }
        'YesNo' {
            $flowLayoutPanel1.Controls.Add($yesButton)
            $flowLayoutPanel1.Controls.Add($noButton)
        }
    }
    $flowLayoutPanel1.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]0,[System.Int32]0))
    $flowLayoutPanel1.Name = [System.String]'flowLayoutPanel1'
    $flowLayoutPanel1.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]484,[System.Int32]106))
    $flowLayoutPanel1.TabIndex = [System.Int32]1
    #
    #okButton
    #
    $okButton.AutoSize = $true
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $okButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]3,[System.Int32]39))
    $okButton.Name = [System.String]'okButton'
    $okButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]30))
    $okButton.TabIndex = [System.Int32]0
    $okButton.Text = [System.String]'OK'
    $okButton.UseVisualStyleBackColor = $true
    #
    #yesButton
    #
    $yesButton.AutoSize = $true
    $yesButton.DialogResult = [System.Windows.Forms.DialogResult]::Yes
    $yesButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]84,[System.Int32]39))
    $yesButton.Name = [System.String]'yesButton'
    $yesButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]30))
    $yesButton.TabIndex = [System.Int32]1
    $yesButton.Text = [System.String]'Yes'
    $yesButton.UseVisualStyleBackColor = $true
    #
    #noButton
    #
    $noButton.AutoSize = $true
    $noButton.DialogResult = [System.Windows.Forms.DialogResult]::No
    $noButton.Location = (New-Object -TypeName System.Drawing.Point -ArgumentList @([System.Int32]165,[System.Int32]39))
    $noButton.Name = [System.String]'noButton'
    $noButton.Size = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]75,[System.Int32]30))
    $noButton.TabIndex = [System.Int32]2
    $noButton.Text = [System.String]'No'
    $noButton.UseVisualStyleBackColor = $true
    #
    #Form1
    #
    $Form1.AutoSize = $true
    $Form1.AutoSizeMode = [System.Windows.Forms.AutoSizeMode]::GrowAndShrink
    $Form1.ClientSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]484,[System.Int32]110))
    $Form1.Controls.Add($flowLayoutPanel1)
    $Form1.Font = (New-Object -TypeName System.Drawing.Font -ArgumentList @([System.String]'Microsoft Sans Serif',[System.Single]12))
    $Form1.FormBorderStyle = [System.Windows.Forms.FormBorderStyle]::FixedToolWindow
    $Form1.MinimumSize = (New-Object -TypeName System.Drawing.Size -ArgumentList @([System.Int32]500,[System.Int32]100))
    $Form1.Name = [System.String]'Form1'
    $Form1.Text = $Title
    $Form1.StartPosition = [System.Windows.Forms.FormStartPosition]::CenterScreen
    $flowLayoutPanel1.ResumeLayout($false)
    $flowLayoutPanel1.PerformLayout()
    $Form1.ResumeLayout($false)
    Add-Member -InputObject $Form1 -Name base -Value $base -MemberType NoteProperty
    Add-Member -InputObject $Form1 -Name label1 -Value $label1 -MemberType NoteProperty
    Add-Member -InputObject $Form1 -Name flowLayoutPanel1 -Value $flowLayoutPanel1 -MemberType NoteProperty
    Add-Member -InputObject $Form1 -Name okButton -Value $okButton -MemberType NoteProperty
    Add-Member -InputObject $Form1 -Name yesButton -Value $yesButton -MemberType NoteProperty
    Add-Member -InputObject $Form1 -Name noButton -Value $noButton -MemberType NoteProperty
    Add-Member -InputObject $Form1 -Name button1 -Value $button1 -MemberType NoteProperty

    $Form1.ShowDialog()
}

Function Global:Update-TreeViewMembers () {
    #Populates TreeViews to show users, groups, or admins. Useful for selecting managers or join rights.
    #TreeView can technically be another TreeNode as well.
    Param(
        [Parameter(Mandatory)]
        $TreeView,

        [Parameter(Mandatory)]
        [String]$SearchBase,

        [Parameter(Mandatory)]
        [String]$Filter,

        [Parameter(Mandatory)]
        [ValidateSet('User','Group')]
        [String]$ObjectType
    )
    
    Switch($ObjectType) {
        'User' {
            if($credentials -eq [System.Management.Automation.PSCredential]::Empty) {
                Get-ADUser -LDAPFilter $Filter -SearchBase $SearchBase -Server $DC | ForEach-Object {
                    Add-Node -parentNode $TreeView -nodeName $_.DistinguishedName -nodeText $_.Name
                }
            } else {
                Get-ADUser -LDAPFilter $Filter -SearchBase $SearchBase -Server $DC -Credential $credentials | ForEach-Object {
                    Add-Node -parentNode $TreeView -nodeName $_.DistinguishedName -nodeText $_.Name
                }
            }
        }
        'Group' {
            if($credentials -eq [System.Management.Automation.PSCredential]::Empty) {
                Get-ADGroup -LDAPFilter $Filter -SearchBase $SearchBase -Server $DC | ForEach-Object {
                    Add-Node -parentNode $TreeView -nodeName $_.DistinguishedName -nodeText $_.Name
                }
            } else {
                Get-ADGroup -LDAPFilter $Filter -SearchBase $SearchBase -Server $DC -Credential $credentials | ForEach-Object {
                    Add-Node -parentNode $TreeView -nodeName $_.DistinguishedName -nodeText $_.Name
                }
            }
        }
    }
}

Function Global:Write-Log {
    #Logs in CMTrace format. Creates folder in LocalAppData to store errors for the forms.
    #Currently using in conjunction with ($_ | Out-String) in catch blocks
    Param(
        [Parameter(Mandatory)]
        [String]$Message,

        [String]$Component,

        [Parameter(Mandatory)]
        [ValidateSet("Info","Warning","Error")]
        [String]$Type = "Info",

        [Parameter(Mandatory)]
        [String]$LogName
    )
    
    #If APPDATA\Local\Admin-Scripts folder does not exist, create it
    if(!(Test-Path "$env:LOCALAPPDATA\Admin-Scripts")){
        New-Item "$env:LOCALAPPDATA\Admin-Scripts" -ItemType Directory
    }

    #Convert string for type to required format
    Switch ($Type) {
        "Info"      {[int]$Type = 1}
        "Warning"   {[int]$Type = 2}
        "Error"     {[int]$Type = 3}
    }

    #Format the log entry
    $Content = "<![LOG[$Message]LOG]!>" +`
        "<time=`"$(Get-Date -Format "HH:mm:ss.ffffff")`" " +`
        "date=`"$(Get-Date -Format "M-d-yyyy")`" " +`
        "component=`"$Component`" " +`
        "context=`"$([System.Security.Principal.WindowsIdentity]::GetCurrent().Name)`" " +`
        "type=`"$Type`" " +`
        "thread=`"$([Threading.Thread]::CurrentThread.ManagedThreadId)`" " +`
        "file=`"`">"

    #Write to file
    Add-Content -Path "$env:LOCALAPPDATA\Admin-Scripts\$LogName.log" -Value $Content
}

Function Check-ScriptHash {
    #Retool of the old way of updating admin scripts. Only used for this script.
    #Updates and relaunches script only if changes were made to the domain copy.
    Param(
        [Switch]$Beta
    )

    $ScriptName = (Split-Path $PSCommandPath -Leaf)
    $hashDest = Get-FileHash $PSCommandPath -Algorithm "SHA256"
    if($Beta){
        $hashSrc = Get-FileHash "$env:LOGONSERVER\netlogon\Administration_Scripts\BetaAdmin_Scripts\$ScriptName" -Algorithm "SHA256"
        if ($hashSrc.Hash -ne $hashDest.Hash) {
            Write-Warning "Your script is not up to date! Updating Now..."
            robocopy.exe "$env:LOGONSERVER\netlogon\Administration_Scripts\BetaAdmin_Scripts" "$env:SystemDrive\BetaAdmin_Scripts" $ScriptName | Out-Null
            $CommandLine = "-File `"" + $PSCommandPath + "`" "
            Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
            Exit
        }
    } else {
        $hashSrc = Get-FileHash "$env:LOGONSERVER\netlogon\Administration_Scripts\Production_Scripts\$ScriptName" -Algorithm "SHA256"
        if ($hashSrc.Hash -ne $hashDest.Hash) {
            robocopy.exe "$env:LOGONSERVER\netlogon\Administration_Scripts\Production_Scripts" "$env:SystemDrive\Administration_Scripts" $ScriptName | Out-Null
            $CommandLine = "-WindowStyle Hidden -File `"" + $PSCommandPath + "`" "
            Start-Process -FilePath PowerShell.exe -Verb Runas -ArgumentList $CommandLine
            Exit
        }
    }
}
#endregion Functions

#Import and show loading screen
. (Join-Path $resourcesFolder 'LoadingScreen.designer.ps1')
$loadingScreen.Show()

#Check for Active Directory Module
try{
    Import-Module ActiveDirectory -ErrorAction Stop
} catch {
    $loadingScreen.Close() #Close LoadingScreen to show user other messages
    Write-Log -Message ($_ | Out-String) -Component "Importing Module" -Type Error -LogName Admin-Scripts #Write the error to the log JIC

    #Prompt the user to install RSAT
    if([System.Windows.Forms.MessageBox]::Show("You are missing the Active Directory Module. Would you like to install it now?","Missing RSAT Tools!","YesNo") -eq 'Yes') {
        try {
            Start-Process -FilePath powershell.exe -ArgumentList "-file $(Join-Path $PSScriptRoot 'Install-RSAT.ps1')" -Verb RunAs -Wait
            Import-Module ActiveDirectory -Global -ErrorAction Stop
        } catch {
            [System.Windows.Forms.MessageBox]::Show("Failed to install RSAT tools. Please manually install before running again.","RSAT Error!")
            Exit
        }
    } else {
        [System.Windows.Forms.MessageBox]::Show("Script Exiting. Prerequisites not installed.","Missing RSAT Tools!")
        Exit
    }
}

#region DataTables

#Add all applicable Employee Type Codes here
#This should mirror the IAO forms, I commented out the ones I don't think will be on SIPR.
$Global:eTypeArray = New-Object System.Data.DataTable
[Void]$eTypeArray.Columns.Add('DisplayName', 'System.String')
[Void]$eTypeArray.Columns.Add('PCC', 'System.String')
[Void]$eTypeArray.Rows.Add('Active Duty Personnel','A')
[Void]$eTypeArray.Rows.Add('Presidential Appointee','B')
[Void]$eTypeArray.Rows.Add('DoD Civil Service Employee','C')
#[Void]$eTypeArray.Rows.Add('Disabled American Veteran','D')
[Void]$eTypeArray.Rows.Add('DoD Contract Employee','E')
#[Void]$eTypeArray.Rows.Add('Former Member','F')
#[Void]$eTypeArray.Rows.Add('Organizational Account','G')
#[Void]$eTypeArray.Rows.Add('Medal of Honor Recipient','H')
[Void]$eTypeArray.Rows.Add('Non-DoD Civil Service Employee','I')
[Void]$eTypeArray.Rows.Add('Academy Student','J')
[Void]$eTypeArray.Rows.Add('Non-appropriated funds','K')
#[Void]$eTypeArray.Rows.Add('Lighthouse Service','L')
[Void]$eTypeArray.Rows.Add('Non-Government Agency Personnel','M')
[Void]$eTypeArray.Rows.Add('National Guard Member','N')
[Void]$eTypeArray.Rows.Add('Non-Dod Contract Employee','O')
#[Void]$eTypeArray.Rows.Add('Dual Persona Test Accounts','P')
#[Void]$eTypeArray.Rows.Add('Grey Area Retiree','Q')
[Void]$eTypeArray.Rows.Add('Retired Military Member','R')
#[Void]$eTypeArray.Rows.Add('Resource Accounts','S')
[Void]$eTypeArray.Rows.Add('Foreign Military Member','T')
[Void]$eTypeArray.Rows.Add('Foreign National Employee','U')
[Void]$eTypeArray.Rows.Add('Reserve Member','V')
[Void]$eTypeArray.Rows.Add('Kiosk Account','X')
#[Void]$eTypeArray.Rows.Add('Multi-User Account','Y')
#[Void]$eTypeArray.Rows.Add('Administrative Account','Z')

#This array holds all the branches available for selection in the form.
#The combobox is unordered in order to allow the most commonly used items at the top.
$Global:Branches = @(
    'USAF'
    'USA'
    'USMC'
    'USN'
    'USSF'
)

#This array holds all the payplans available for selection in the form.
#The combobox is unordered in order to allow the most commonly used items at the top.
$Global:PayPlans = @(
    'ME'
    'MO'
    'GS'
    'GG'
    '99'
    'MW'
    'NH'
    'ND'
    'ES'
)

#This array holds all the suffix/generational qualifiers available for selection in the form.
#The combobox is unordered in order to allow the most commonly used items at the top.
$Global:SuffixList = @(
    ''
    'Jr'
    'SR'
    'I'
    'II'
    'III'
    'IV'
    'V'
)

#Add all admin type codes that bases can use here. Values pulled from MPTO 00-33D-2001.
#This list is available to bases and NOS, use the 'if ($NOSOverride) {' section to add the rest.
$Global:AdmTypeArray = New-Object System.Data.DataTable
[Void]$AdmTypeArray.Columns.Add('DisplayName', "System.String")
[Void]$AdmTypeArray.Columns.Add('adminTypeCode', "System.String")
[Void]$AdmTypeArray.Rows.Add('Application Operator/Administrator','A')
[Void]$AdmTypeArray.Rows.Add('Functional Server Administrator','F')
[Void]$AdmTypeArray.Rows.Add('Workstation Administrator','W')

#Add all applicable Computer Type Codes here. Values pulled from MPTO 00-33D-2001.
$Global:cTypeArray = New-Object System.Data.DataTable
[Void]$cTypeArray.Columns.Add('DisplayName', "System.String")
[Void]$cTypeArray.Columns.Add('computerTypeCode', "System.String")
[Void]$cTypeArray.Rows.Add('Laptop','L')
[Void]$cTypeArray.Rows.Add('Tablet','T')
[Void]$cTypeArray.Rows.Add('Virtual','V')
[Void]$cTypeArray.Rows.Add('Workstation','W')
#endregion DataTables
#endregion Variables

#region Validation
$Global:serviceAccountNameTextbox_Validating = {
	$_.Cancel = $this.Text -notmatch '^[$]*SVC\.\w+\.\w+$'
    #May be $SVC.GeoCode.Name or SVC.GeoCode.Name
    if($_.Cancel) {
        $errorprovider1.SetError($this, 'Format: <$Type>[DOT]<Scope>[DOT]<Function>. Maximum of 20 Characters.')
    }
}

$Global:firstNameTextbox_Validating = {
    $_.Cancel = $this.Text -notmatch "^[a-zA-Z](?:[_\-a-zA-Z]*[a-zA-Z])?$"
    #Must only be letters, spaces, or hyphens
    if($_.Cancel) {
        $errorprovider1.SetError($this, "Punctuation is not permitted (exception: spaces and hyphens are allowed)." + [System.Environment]::NewLine +
            "If the name includes a blank space, an underscore (_) will be used to fill the blank space.")
    }
}

$Global:lastNameTextbox_Validating = {
    $_.Cancel = $this.Text -notmatch "^[a-zA-Z](?:['\-a-zA-Z]*[a-zA-Z])?$"
    #Must only be letters, apostrophes, and hyphens
    if($_.Cancel) {
        $errorprovider1.SetError($this, "The legal family name of the individual. Punctuation is not permitted" + [System.Environment]::NewLine +
            "(exception: apostrophes and hyphens, as commonly used in married names, are allowed).")
    }
}

$Global:initialTextbox_Validating = {
    $_.Cancel = $this.Text -notmatch '^[a-zA-Z]*$'
    #May be one letter or left empty
    if($_.Cancel) {
        $errorprovider1.SetError($this, "The individual’s legal middle initial. Leave blank for individuals who do not have a middle name.")
    }
}

$Global:citizenshipTextbox_Validating = {
    $_.Cancel = $this.Text -notmatch '^[a-zA-Z]{2}$'
    #Must be two letters only
    if($_.Cancel) {
        $errorprovider1.SetError($this, "Two letter country code for users citizenship.")
    }
}

$Global:edipiTextbox_Validating = {
	$_.Cancel = $this.Text -notmatch '^1\d{9}$'
    #Must be 1 followed by 9 digits only
    if($_.Cancel) {
        $errorprovider1.SetError($this, "EDIPI is a 10 digit number starting with 1.")
    }
}

$Global:stateTextbox_Validating = {
    $_.Cancel = $this.Text -notmatch '^[a-zA-Z]{2}$|^$'
    #May be exactly two letters or left blank
    if($_.Cancel) {
        $errorprovider1.SetError($this, "Two letter state code where user is stationed. If city is not in a state" + [System.Environment]::NewLine +
            "(e.g., Outside the Continental United States [OCONUS] addresses), then leave blank.")
    }
}

$Global:countryTextbox_Validating = {
    $_.Cancel = $this.Text -notmatch '^[a-zA-Z]{2}$'
    #Must be two letters only
    if($_.Cancel) {
        $errorprovider1.SetError($this, "Two letter country code where user is stationed.")
    }
}

$Global:zipTextbox_Validating = {
    $_.Cancel = $this.Text -notmatch '^\d{5}$'
    #Must be 5 digits only
    if($_.Cancel) {
        $errorprovider1.SetError($this, "The ZIP/postal code for the duty location provided in the locality attribute.")
    }
}

$Global:phoneTextbox_Validating = {
    $_.Cancel = $this.Text -notmatch '^(\d{3}[-]){2}(\d{4})$'
    #Must be 3 digits - 3 digits - 4 digits only
    if($_.Cancel) {
        $errorprovider1.SetError($this, "Format is <312>-<555>-<1234>")
    }
}

$Global:emailTextbox_Validating = {
    $_.Cancel = $this.Text -notmatch '^[a-zA-Z0-9\.\-]+@mail\.smil\.mil$'
    #Must be letters, numbers, . or - followed by @mail.smil.mil
    if($_.Cancel) {
        $errorprovider1.SetError($this, "SIPR email that should end in @mail.smil.mil.")
    }
}

$Global:ownerEmailTextbox_Validating = {
    $_.Cancel = $this.Text -notmatch '^[a-zA-Z0-9\.\-]+@mail\.smil\.mil$'
    #Must be letters, numbers, . or - followed by @mail.smil.mil
    if($_.Cancel) {
        $errorprovider1.SetError($this, "SIPR Org Box or Distro List that should end in @mail.smil.mil.")
    }
}

$Global:homeDriveTextbox_Validating = {
    $_.Cancel = $this.Text -notmatch '^\\(\\[\w\.\-\ \(\)]+){2,}(\\?)$|^$'
    #Must be \\server\share containing . - _ spaces or () or left blank
    if($_.Cancel) {
        $errorprovider1.SetError($this, "Enter a valid network server path using the form: \\server\share\folder.")
    }
}

$Global:CRQTextbox_Validating = {
    $_.Cancel = $this.Text -notmatch '^CRQ\d{12}$|^WO\d{13}$'
    #Must be CRQ############ or WO#############
    if($_.Cancel) {
        $errorprovider1.SetError($this, "The Change Request (CRQ) or Work Order (WO) number authorizing the" + [System.Environment]::NewLine +
            "creation of the service account using the format of `“CRQ############`” or `“WO#############`"")
    }
}

$Global:systemIdTextBox_Validating = {
    $_.Cancel = $this.Text -notmatch '^\w+$'
    #Alphanumeric characters only
    if($_.Cancel) {
        $errorprovider1.SetError($this, "Only alphanumeric characters are allowed.")
    }
}

$Global:validating_NotBlank = {
    $_.Cancel = $this.Text -match '^$'
    #Must not be blank
    if($_.Cancel) {
        $errorprovider1.SetError($this, "This field must not be left blank.")
    }
}

$Global:pathTextbox_Validating = {
    $_.Cancel = $this.Text -match '^$'
    #Must select a location on the TreeView
    if($_.Cancel) {
        $errorprovider1.SetError($this, "Please select a location to create this object from the TreeView on the left.")
    }
}

$Global:control_Validated = {
    $errorprovider1.SetError($this, '')
}
#endregion Validation

if ($NOSOverride) {
    #Add the remaining admin type codes to the NOS selection
    [Void]$AdmTypeArray.Rows.Add('Critical Server Adminstrator','C')
    [Void]$AdmTypeArray.Rows.Add('Domain Administrator','D')
    [Void]$AdmTypeArray.Rows.Add('Enterprise Administrator','E')
    [Void]$AdmTypeArray.Rows.Add('Public Facing Server Administrator','X')

    #Show NOSLauncher
    $loadingScreen.Close()
    . (Join-Path $launchersFolder 'NOSLauncher.ps1')
} else {
    #This verifies that the script is up to date for the user before launching the rest of them
    if($Beta) {
        Check-ScriptHash -Beta
    } else {
        Check-ScriptHash
    }
    
    $Global:Domain = Get-ADDomain #No need to do special filtering since base admin will be on same network
    $Global:DC = (Get-ADDomainController).HostName #Find closest domain controller to communicate with
    $formUser = Get-ADUser $env:USERNAME -Properties l -Server $DC #Get the users account info
    $Global:formUserMembership = Get-ADGroup -LDAPFilter ("(member:1.2.840.113556.1.4.1941:={0})" -f $formUser.DistinguishedName) -Server $DC | 
        Select-Object -ExpandProperty Name #Get the users groups
    $Global:baseNames = Get-BaseNames #Gather Base Names from the 'Bases' OU

    #This verifies that the script is up to date for the user before launching the rest of them
    if($Beta) {
        Update-AdminScripts -Beta
    } else {
        Update-AdminScripts
    }

    #Show BaseLauncher
    $loadingScreen.Close()
    . (Join-Path $launchersFolder 'BaseLauncher.ps1')
}
