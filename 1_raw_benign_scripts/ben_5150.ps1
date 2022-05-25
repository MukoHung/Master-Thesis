<#
.SYNOPSIS
    Header file to create user dialog box.
.DESCRIPTION
    A script to create a user dialog box. This script always runs from another
    script's call.
.NOTES
    File Name  : User-Prompts.ps1
    Author     : Dan Gill - dgill@gocloudwave.com
.INPUTS
    None. You cannot pipe objects to User-Prompts.ps1.
.OUTPUTS
    None. User-Prompts.ps1 does not generate output.
.EXAMPLE
    PS> .\User-Prompts.ps1
#>

<#
.SYNOPSIS
    Create user dialog box with single list item selection.
.DESCRIPTION
    Create user dialog box with single list item selection.
    Takes a Title, Message, List, and optional size parameters.
.PARAMETER Title
    Specifies the name of the dialog box.
.PARAMETER Prompt
    Specifies the message to prompt the user.
.PARAMETER Values
    Specifies an array to list for single selection.
.PARAMETER Width
    Specifies the width of the dialog box. Defaults to 300 pixels.
.PARAMETER Height
    Specifies the height of the dialog box. Defaults to 200 pixels.
.LINK
    https://docs.microsoft.com/en-us/powershell/scripting/samples/selecting-items-from-a-list-box?view=powershell-7.2
.INPUTS
    None. You cannot pipe objects to myDialogBox.
.OUTPUTS
    System.String. myDialogBox returns a string with the selected item.
.EXAMPLE
    PS> $SelectedItem = myDialogBox -Title 'Title' -Prompt 'Message' `
    -Values $SelectionList
.EXAMPLE
    PS> $SelectedItem = myDialogBox -Title 'Title' -Prompt 'Message' `
    -Values $SelectionList -Width 400
.EXAMPLE
    PS> $SelectedItem = myDialogBox -Title 'Title' -Prompt 'Message' `
    -Values $SelectionList -Height 400
.EXAMPLE
    PS> $SelectedItem = myDialogBox -Title 'Title' -Prompt 'Message' `
    -Values $SelectionList -Width 400 -Height 400
#>
function myDialogBox {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string[]]$Title,
        [Parameter(Mandatory)]
        [string[]]$Prompt,
        [Parameter(Mandatory)]
        [string[]]$Values,
        [Parameter(Mandatory = $false)]
        [Int]$Width = 300,
        [Parameter(Mandatory = $false)]
        [Int]$Height = 200
    )

    Add-Type -AssemblyName System.Windows.Forms
    Add-Type -AssemblyName System.Drawing

    $buttonWidth = 75
    $buttonHeight = 23
    $buttonTopEdge = $Height - 80
    $OKbuttonLeftEdge = ( $Width / 2 ) - $buttonWidth
  
    $form = New-Object System.Windows.Forms.Form
    $form.Text = $Title
    $form.Size = New-Object System.Drawing.Size($Width, $Height)
    $form.StartPosition = 'CenterScreen'
  
    $okButton = New-Object System.Windows.Forms.Button
    $okButton.Location = New-Object System.Drawing.Point($OKbuttonLeftEdge, $buttonTopEdge)
    $okButton.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
    $okButton.Text = 'OK'
    $okButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.AcceptButton = $okButton
    $form.Controls.Add($okButton)
  
    $cancelButton = New-Object System.Windows.Forms.Button
    $cancelButton.Location = New-Object System.Drawing.Point( ( $Width / 2 ), $buttonTopEdge)
    $cancelButton.Size = New-Object System.Drawing.Size($buttonWidth, $buttonHeight)
    $cancelButton.Text = 'Cancel'
    $cancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.CancelButton = $cancelButton
    $form.Controls.Add($cancelButton)
  
    $label = New-Object System.Windows.Forms.Label
    $label.Location = New-Object System.Drawing.Point(10, 20)
    $label.Size = New-Object System.Drawing.Size(($Width - 20), 20)
    $label.Text = $Prompt
    $form.Controls.Add($label)
  
    $listBox = New-Object System.Windows.Forms.ListBox
    $listBox.Location = New-Object System.Drawing.Point(10, 40)
    $listBox.Size = New-Object System.Drawing.Size(($Width - 40), 20)
    $listBox.Height = $Height - 120
  
    foreach ($value in $Values)
    { [void] $listBox.Items.Add($value) }
  
    $form.Controls.Add($listBox)
  
    $form.Topmost = $true
  
    $form.Add_Shown({ $listBox.Select() })
  
    $result = $form.ShowDialog()
  
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        $x = $listBox.SelectedItem
        return $x
    } else {
        # The user canceled, so exit the script. If the user canceled after connecting to vCenter, disconnect first.
        try {
            Disconnect-VIServer * -Confirm:$false
            Write-Warning 'User canceled dialog box. Exiting script.'
        } catch { Write-Warning 'Exiting before selecting a vCenter.' }
        finally { Exit }
    }
    
}