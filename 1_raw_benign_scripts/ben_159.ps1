Add-Type -AssemblyName "System.Windows.Forms"
Add-Type -AssemblyName "System.Drawing"

function mainform {
cls
    $form=New-Object System.Windows.Forms.Form
    $form.Text="TSTech Uk Ltd IT's Useful Tools Form."
    $form.Location.X=100
    $form.Location.Y=100
    $form.Size=New-Object System.Drawing.Size(600,600)

# Bios Info and Mac Address
    $biosinfobtn=New-Object System.Windows.Forms.Button
    $biosinfobtn.Location = New-Object System.Drawing.Size(5,30)
    $biosinfobtn.Size = New-Object System.Drawing.Size(96,32)
    $biosinfobtn.Text = "Machine Bios Information"
    $biosinfobtn.Add_Click({
    & 'H:\01 Admin\19 Office Systems\Scripting\Powershell\Windows Forms MC Bios info.ps1'
    })

    $Form.Controls.Add($biosinfobtn)

# Create New FTP User
    $ftpcreatebtn=New-Object System.Windows.Forms.Button
    $ftpcreatebtn.Location = New-Object System.Drawing.Size(120,30)
    $ftpcreatebtn.Size = New-Object System.Drawing.Size(96,32)
    $ftpcreatebtn.Text = "Create New FTP User"
    $ftpcreatebtn.Add_Click({
    & 'H:\01 Admin\19 Office Systems\Scripting\Powershell\Create FTP Account\Create New FTP Customer.ps1'
    })
    $Form.Controls.Add($ftpcreatebtn)

# Get an AD Users GroupMembership    
    $usergrpsbtn=New-Object System.Windows.Forms.Button
    $usergrpsbtn.Location = New-Object System.Drawing.Size(120,75)
    $usergrpsbtn.Size = New-Object System.Drawing.Size(96,32)
    $usergrpsbtn.Text = "User - Group Membership"
    $usergrpsbtn.Add_Click({
    & 'H:\01 Admin\19 Office Systems\Scripting\Powershell\usrgrps.ps1'
    })
    $Form.Controls.Add($usergrpsbtn)

# Import AD Users in Bulk
    $userbuadimpbtn=New-Object System.Windows.Forms.Button
    $userbuadimpbtn.Location = New-Object System.Drawing.Size(5,75)
    $userbuadimpbtn.Size = New-Object System.Drawing.Size(96,32)
    $userbuadimpbtn.Text = "Import - Bulk AD Users"
    $userbuadimpbtn.Add_Click({
    & 'H:\01 Admin\19 Office Systems\Scripting\Powershell\bulkuseradimport.ps1'
    })
    $Form.Controls.Add($userbuadimpbtn)

# AD Users to IBM Notes Export
    $ADtoNotesbtn=New-Object System.Windows.Forms.Button
    $ADtoNotesbtn.Location = New-Object System.Drawing.Size(5,120)
    $ADtoNotesbtn.Size = New-Object System.Drawing.Size(96,32)
    $ADtoNotesbtn.Text = "AD to Notes Export"
    $ADtoNotesbtn.Add_Click({
    & 'H:\01 Admin\19 Office Systems\Scripting\Powershell\AD to Notes Export.ps1'
    })
    $Form.Controls.Add($ADtoNotesbtn)
# AD Account Lockout Events
    $ADlckoutbtn=New-Object System.Windows.Forms.Button
    $ADlckoutbtn.Location = New-Object System.Drawing.Size(120,120)
    $ADlckoutbtn.Size = New-Object System.Drawing.Size(96,32)
    $ADlckoutbtn.Text = "AD Account Lockout"
    $ADlckoutbtn.Add_Click({
    & 'H:\01 Admin\19 Office Systems\Scripting\Powershell\ADlockout2.ps1'
    })
    $Form.Controls.Add($ADlckoutbtn)
# List all Domino Groups to a file
    $DomGrplistallbtn=New-Object System.Windows.Forms.Button
    $DomGrplistallbtn.Location = New-Object System.Drawing.Size(5,165)
    $DomGrplistallbtn.Size = New-Object System.Drawing.Size(96,32)
    $DomGrplistallbtn.Text = "Domino Group List Export"
    $DomGrplistallbtn.Add_Click({
    & 'H:\01 Admin\19 Office Systems\Scripting\Powershell\Domino PS Scripts\PS-DomGrplistAll.ps1'
    })
    $Form.Controls.Add($DomGrplistallbtn)
# Export all Domino Email Addresses to a file
    $DomEMExportbtn=New-Object System.Windows.Forms.Button
    $DomEMExportbtn.Location = New-Object System.Drawing.Size(5,210)
    $DomEMExportbtn.Size = New-Object System.Drawing.Size(96,32)
    $DomEMExportbtn.Text = "Domino Email Address Export"
    $DomEMExportbtn.Add_Click({
    & 'H:\01 Admin\19 Office Systems\Scripting\Powershell\Domino PS Scripts\PS-DomAllEmailAddresses.ps1'
    })
    $Form.Controls.Add($DomEMExportbtn)
# Domino Database ACL List
    $DomDBACLListbtn=New-Object System.Windows.Forms.Button
    $DomDBACLListbtn.Location = New-Object System.Drawing.Size(120,210)
    $DomDBACLListbtn.Size = New-Object System.Drawing.Size(96,32)
    $DomDBACLListbtn.Text = "Domino DBase ACL List"
    $DomDBACLListbtn.Add_Click({
    & 'H:\01 Admin\19 Office Systems\Scripting\Powershell\Domino PS Scripts\PS-DomDBACLList.ps1'
    })
    $Form.Controls.Add($DomDBACLListbtn)
# Domino Database ACL List
    $DomGrpListMembtn=New-Object System.Windows.Forms.Button
    $DomGrpListMembtn.Location = New-Object System.Drawing.Size(120,210)
    $DomGrpListMembtn.Size = New-Object System.Drawing.Size(96,32)
    $DomGrpListMembtn.Text = "Domino DBase ACL List"
    $DomGrpListMembtn.Add_Click({
    & 'H:\01 Admin\19 Office Systems\Scripting\Powershell\Domino PS Scripts\PS-DomGrplistMembers.ps1'
    })
    $Form.Controls.Add($DomGrpListMembtn)

    # Display an Image on a form
    $image = [System.Drawing.Image]::Fromfile('H:\01 Admin\19 Office Systems\Scripting\Powershell\Images\TsTechLogo.png')     
    $pictureBox = new-object Windows.Forms.PictureBox  #--instantiates a PictureBox
    $pictureBox.Image=$image
    $pictureBox.Location = New-object System.Drawing.Size(415,5)
    $pictureBox.Width =  $image.Size.Width
    $pictureBox.Height =  $image.Size.Height
    $pictureBox.Image = $image
    $pictureBox.Anchor = [System.Windows.Forms.AnchorStyles]::Bottom
    $form.controls.add($pictureBox)

# Domain Textbox - top left
    $TextBox3 = New-Object System.Windows.Forms.TextBox 
    $TextBox3.Location = New-Object System.Drawing.Size(5,5) 
    $TextBox3.Size = New-Object System.Drawing.Size(210,72)
    $Font = New-Object System.Drawing.Font("Tahoma",8,[System.Drawing.FontStyle]::regular)
    $TextBox3.Font=$Font
    $gdm=get-addomain | select dnsroot
    $gdm1=$gdm.dnsroot.tostring()
        
    $body1 = @"
    Current Domain:
    $gdm1
"@
    $Textbox3.text=$body1
    $Form.Controls.Add($Textbox3)

    $Exitbutton=New-Object System.Windows.Forms.Button
    $Exitbutton.Location = New-Object System.Drawing.Size(470,520)
    $Exitbutton.Size = New-Object System.Drawing.Size(100,32)
    $Exitbutton.Text = "Exit"
    $Exitbutton.add_click({$Form.Close()})

    $Form.Controls.Add($Exitbutton)

    $form.ShowDialog()
    }

mainform