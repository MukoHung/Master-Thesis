# ------------------------------------------------------------------------------------------------------------------------------
#
# Darkhand's print spooler tools v5.0
# 
# Use this to remotely query or restart the print spooler of a given machine. Also can reboot the machine remotely (untested).
#
# ------------------------------------------------------------------------------------------------------------------------------
#
#
# Changes in v5.0:
#
#       * Place cursor in the machine name textbox at start.
#
#       * Pressing enter in the machine name textbox queries status by default.
#
#       * Set the results textbox to read only (no need to type in that box anyway).
#
#       * Remove the unnecessary maximize button on the GUI window
#
#       * Remove window resize.
#
#
# Changes in v4.0:
#
#       * Fix the additional query after restarting the spooler so it actually, you know, works.
#
#
# Changes in v3.0:
#
#
#       * Fix wrong function call attached to the Respool button (oops).
#
#       * Further comments and code cleanup.
#
#       * Added an additional query after restarting the spooler, to show if it succeeded or not.
#
#
# Changes in v2.0:
#
#       * Added a checkbox to enable/disable the 'Restart PC' button, to prevent accidental reboots.
#
#       * Commented out the admin elevation hack at the start of the script.  Uncomment if you have issues with the script
#         erroring out and requiring admin access.
#
#       * Improved code indentation for readability.
#
#
# Changes in v1.0:
#
#       * Initial release.
#
#
# TODO for future versions -or- challenges for Matt:
#
#       * Move the Ping code that's repeated multiple times into its own function.
#
#       * Handle blank entries in the 'computerName' field instead of just puking.
#
#       * Hide the console window that's behind the GUI window.
#
#       * Add the ability to remotely delete a target's print queue folder, for stuck print jobs.
#         (Tried, but doesn't always work. Seems to require WinRM on the target.
#          Need to script a WinRM checker and remote installer before reimplementing.)
#
#       * Also add one-click clearing of Chrome/IE cache files.
#
#       * Any other commonly used thingies requested by Matt.
#
#
# ------------------------------------------------------------------------------------------------------------------------------


# ------ BEGIN ------


# If script is not run as administrator, close it and reopen with admin rights (This code stolen from https://gist.github.com/atao/a103e443ffb37d5d0f0e7097e4342a28)
# (Uncomment the below line only if you have issues with commands erroring out and requiring admin access).
#
# if (!([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) { Start-Process powershell.exe "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs; exit }


# Add a GUI
#
Add-Type -AssemblyName System.Windows.Forms
[System.Windows.Forms.Application]::EnableVisualStyles()


# Define the GUI objects.
#
$QuerySpoolerButton              = New-Object system.Windows.Forms.Button
$QuerySpoolerButton.text         = "Query print spooler"
$QuerySpoolerButton.width        = 140
$QuerySpoolerButton.height       = 48
$QuerySpoolerButton.location     = New-Object System.Drawing.Point(7,10)
$QuerySpoolerButton.Font         = 'Microsoft Sans Serif,10'

$RespoolButton                   = New-Object system.Windows.Forms.Button
$RespoolButton.text              = "Restart print spooler"
$RespoolButton.width             = 140
$RespoolButton.height            = 48
$RespoolButton.location          = New-Object System.Drawing.Point(7,61)
$RespoolButton.Font              = 'Microsoft Sans Serif,10'

$RestartComputerButton           = New-Object system.Windows.Forms.Button
$RestartComputerButton.text      = "Restart Computer"
$RestartComputerButton.width     = 140
$RestartComputerButton.height    = 48
$RestartComputerButton.enabled   = $false
$RestartComputerButton.location  = New-Object System.Drawing.Point(7,112)
$RestartComputerButton.Font      = 'Microsoft Sans Serif,10'

$RestartCheckBox                 = New-Object system.Windows.Forms.CheckBox
$RestartCheckBox.text            = "Enable restart"
$RestartCheckBox.AutoSize        = $false
$RestartCheckBox.width           = 120
$RestartCheckBox.height          = 20
$RestartCheckBox.enabled         = $true
$RestartCheckBox.location        = New-Object System.Drawing.Point(8,160)
$RestartCheckBox.Font            = 'Microsoft Sans Serif,9'

$ComputerNameText                = New-Object system.Windows.Forms.Label
$ComputerNameText.text           = "Computer name:"
$ComputerNameText.AutoSize       = $true
$ComputerNameText.width          = 25
$ComputerNameText.height         = 10
$ComputerNameText.location       = New-Object System.Drawing.Point(177,22)
$ComputerNameText.Font           = 'Microsoft Sans Serif,10'

$ComputerName                    = New-Object system.Windows.Forms.TextBox
$ComputerName.multiline          = $false
$ComputerName.width              = 157
$ComputerName.height             = 102
$ComputerName.location           = New-Object System.Drawing.Point(303,17)
$ComputerName.Font               = 'Microsoft Sans Serif,10'

$ResultTexBox                    = New-Object system.Windows.Forms.TextBox
$ResultTexBox.multiline          = $true
$ResultTexBox.ReadOnly           = $true
$ResultTexBox.width              = 283
$ResultTexBox.height             = 106
$ResultTexBox.location           = New-Object System.Drawing.Point(177,55)
$ResultTexBox.Font               = 'Microsoft Sans Serif,10'

$Form                            = New-Object system.Windows.Forms.Form
$Form.ClientSize                 = '470,196'
$Form.text                       = "Printer Tools v5.0"
$Form.TopMost                    = $false
$Form.MaximizeBox                = $false              # Remove the maximize button.
$Form.AcceptButton               = $QuerySpoolerButton # Pressing Enter presses this button.
$Form.FormBorderStyle            = 'Fixed3D'           # Disable window resize.


# Add the objects that are defined above to the panel. The order determines which first gets
# focus, and the tab key ordering.
#
$Form.controls.AddRange(
    @(
        $ComputerName,          # Placing the machine name text box first puts the cursor in the box by default.
        $QuerySpoolerButton,
        $RespoolButton,
        $RestartComputerButton,
        $RestartCheckBox,
        $ResultTexBox,
        $ComputerNameText
     )
)


# Assign actions and functions to the interactible GUI objects.
#
$QuerySpoolerButton.Add_Click({ QuerySpooler })
$RespoolButton.Add_Click({ Respool })
$RestartComputerButton.Add_Click({ RestartPC })
$RestartCheckBox.Add_CheckedChanged({ RestartCheckboxEvent })


# ------ Begin work functions ------


# Function to query the status of a machine's print spooler.
#
function QuerySpooler(){

    $ResultTexBox.Text = "" # Clear the info box on button press.

    # Check to see if the given computer name exists on the network.
    $ResultTexBox.AppendText("Pinging " + $computerName.Text + "...")
    $Exist = Test-Connection -Count 1 -ComputerName $computerName.Text -ErrorAction SilentlyContinue

    # If it doesn't exist, error out.
    If (-Not $Exist) {
        $ResultTexBox.AppendText("`r`n" + $computerName.Text + " is not on the network.")
    }

    # Otherwise go ahead.
        Else {
            $ResultTexBox.AppendText("Ok.") # Ping was good
            $ResultTexBox.AppendText("`r`nQuerying service... ")
        
            # Service name we're looking for.
            $Name = "Print spooler"

            # Query the spooler service.
            $Service = Get-Service -ComputerName $computerName.Text -display $Name -ErrorAction SilentlyContinue
    
            # If the service isn't installed (for some reason), error out.
            If (-Not $Service) {
                $ResultTexBox.AppendText("`r`n" + $Name + " is not installed on " + $computerName.Text + "!")
            }
            
                # Otherwise go ahead.
                Else {
                    $ResultTexBox.AppendText($Name + " is installed.")
                    $ResultTexBox.AppendText("`r`n" + $Name + "'s status is: " + $service.Status)
                }
        }
}


# Function to restart a machine's print spooler.
#
function Respool(){

    $ResultTexBox.Text = "" # Clear the info box on button press.

    # Check to see if the given computer name exists on the network.
    $ResultTexBox.AppendText("Pinging " + $computerName.Text + "...")
    $Exist = Test-Connection -Count 1 -ComputerName $computerName.Text -ErrorAction SilentlyContinue

    # If it doesn't exist, error out.
    If (-Not $Exist) {
        $ResultTexBox.AppendText("`r`n" + $computerName.Text + " is not on the network.")
    }

    # Otherwise go ahead.
        Else {
            $ResultTexBox.AppendText("Ok.") # Ping was good
            $ResultTexBox.AppendText("`r`nQuerying service... ")
        
            # Service name we're looking for.
            $Name = "Print spooler"

            # Query the spooler service.
            $Service = Get-Service -ComputerName $computerName.Text -display $Name -ErrorAction SilentlyContinue
    
            # If the service isn't installed (for some reason), error out.
            If (-Not $Service) {
                $ResultTexBox.AppendText("`r`n" + $Name + " is not installed on " + $computerName.Text + "!")
            }
            
                # Otherwise go ahead.
                Else {
                    $ResultTexBox.AppendText($Name + " is installed.")
                    $ResultTexBox.AppendText("`r`n" + $Name + "'s status is: " + $service.Status)
                
                    # Restart the service
                    $ResultTexBox.AppendText("`r`nSending restart... ")
                    Get-Service -ComputerName $computerName.Text -display $Name -ErrorAction SilentlyContinue | Restart-Service #-ErrorAction SilentlyContinue
                    $ResultTexBox.AppendText("Done.")
                    
                    # Requery and display the updated status.
                    $Service = Get-Service -ComputerName $computerName.Text -display $Name -ErrorAction SilentlyContinue
                    $ResultTexBox.AppendText("`r`n" + $Name + "'s status is now: " + $service.Status)
                }
        }

}


# Function to restart a machine (TODO: Add a confirmation box).
#
function RestartPC(){

    $ResultTexBox.Text = "" # Clear the info box on button press.

    # Check to see if the given computer name exists on the network.
    $ResultTexBox.AppendText("Pinging " + $computerName.Text + "...")
    $Exist = Test-Connection -Count 1 -ComputerName $computerName.Text -ErrorAction SilentlyContinue

    # If it doesn't exist, error out.
    If (-Not $Exist) {
        $ResultTexBox.AppendText("`r`n" + $computerName.Text + " is not on the network.")
    }

    # Otherwise go ahead.
        Else {
            $ResultTexBox.AppendText("Ok.") # Ping was good
            $ResultTexBox.AppendText("`r`nSending reboot request...")
       
            #Reboot target machine.
            Restart-Computer -ComputerName $computerName.text -Force
            $ResultTexBox.AppendText("`r`nDone.")
        }
}


# Function to enable/disable the PC restart button (no more accidental clicks).
#
function RestartCheckboxEvent {

    If ($RestartCheckBox.Checked) {
        $RestartComputerButton.Enabled = $true
    }
        Else {
            $RestartComputerButton.Enabled = $false
        }
}


[void]$Form.ShowDialog() # Show the GUI built at the beginning of the script.