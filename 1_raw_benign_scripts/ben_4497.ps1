<#
 # Little utility to display a toast msg when your external WAN IP address changes
 # 
 # sample command to throw into a scheduled task
 # -> powershell.exe -noprofile -file {PathToThisScript}.ps1 {YOUR_EXPECTED_EXTERNAL_WAN_IP}
 # 
 #>

$expectedIpAddress = $args[0]
$ipaddressFound = 'NOT FOUND'

function display-toast($message, $title) {
    [reflection.assembly]::LoadWithPartialName( "System.Windows.Forms") | Out-Null;
    $form = New-Object Windows.Forms.Form
    $form.TopMost = $true;
    $form.ShowInTaskbar = $false;
    $form.Size = New-Object Drawing.Point 450,200
	$form.Text = $title
	
    $timer = New-Object System.Windows.Forms.Timer
    $timer.Interval = 20
    $timer.add_Tick({
        $startPosY -= 10; 
        if ($startPosY -lt [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Height - $form.Height) {
            $timer.Stop();
        }
        else {
           $form.SetDesktopLocation($startPosX, $startPosY);
        }
    })


    $form.add_Load({ 
        $form.SetDesktopLocation($startPosX, $startPosY);
        $timer.Start();
     })

    $startPosX = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Width - $form.Width;
    $startPosY = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea.Height;

    $label = New-Object Windows.Forms.Label
    $label.Location = New-Object Drawing.Point 50,30
    $label.text = $message
    $label.AutoSize = $true

    $form.controls.add($label)
    $form.ShowDialog()
	$form.Close()
    $form = $null;
}

# Get the external WAN IP address.
$res = (new-object net.webclient).DownloadString('http://checkip.dyndns.org') -match 'IP Address: (.*)</body'
if($res) { $ipaddressFound = $matches[1] }
if($expectedIpAddress -ne $ipaddressFound) {
	[System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms") | Out-Null;
	$msg = "Doh! You have a new WAN IP. {0}***************{0}Expected: $expectedIpAddress{0}Actual:      $ipaddressFound{0}***************{0}{0}Go fourth and do what you must with this newly imparted wisdom!" -f [System.Environment]::NewLine
	display-toast $msg 'New WAN IP!'
	'Doh!'
}
else {
	'All''s good'
}
