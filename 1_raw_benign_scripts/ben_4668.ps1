using namespace System.Management.Automation

#requires -Version 5
#requires -Module ActiveDirectory

[CmdletBinding()]
param
(
    [Parameter(Position = 0)]
    [Credential()]
    [PSCredential]
    $Credential = (Get-Credential -UserName 'default' -Message 'This is for password resets')
)

#region General setup
$SW_HIDE, $SW_SHOW = 0, 5
$SW = Add-Type -MemberDefinition @'
[DllImport("User32.dll")]
public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);
'@ -Namespace Win32 -name Functions -PassThru
$hWnd = (Get-Process -Id $PID).MainWindowHandle
Write-Verbose "User32.dll initialized. PS window handle: $hWnd."

Add-Type -AssemblyName PresentationFramework
$app = [System.Windows.Application]::new()
$app.Add_Exit({Stop-Process -Id $PID -Force})
Write-Verbose 'WPF application initialized.'

trap
{
    $null = $SW::ShowWindow($hWnd, $SW_SHOW)
    $PSItem.Exception, $PSItem.InvocationInfo |
        Format-List -Property * -Force
    "`nPress any key to continue..."
    $null = $Host.UI.RawUI.ReadKey()
    $app.Shutdown(1)
    Stop-Process -Id $PID -Force
}

if ([string]::IsNullOrWhiteSpace($Credential.GetNetworkCredential().Password))
{
    throw 'Credential passed must meet minimum password security requirements.'
}
#endregion

#region WPF setup
$xaml = [xml]@'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        Title="Password Reset Tool" WindowStartupLocation="CenterScreen" SizeToContent="WidthAndHeight" ResizeMode="CanMinimize" Topmost="True">
    <Grid Height="400" Width="400">
        <Label Name="UsernameLabel" Content="Username:" VerticalAlignment="Top" FontFamily="Microsoft Sans Serif" FontSize="10" HorizontalAlignment="Left" Margin="20,40,0,0"/>
        <TextBox Name="UsernameTextBox" HorizontalAlignment="Left" Height="23" VerticalAlignment="Top" Width="126" Margin="84,39,0,0" FontFamily="Microsoft Sans Serif" FontSize="10" VerticalContentAlignment="Center" HorizontalScrollBarVisibility="Auto"/>
        <Button Name="SearchButton" Content="Search" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="225,41,0,0" IsDefault="True" IsEnabled="False"/>
        <Button Name="ClearButton" Content="Clear" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="315,41,0,0"/>
        <Label Name="ADNameLabel" Content="" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="20,96,0,0" Width="280" Visibility="Hidden"/>
        <Label Name="ADEnabledLabel" Content="" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="20,137,0,0" Width="280" Visibility="Hidden"/>
        <Label Name="ADLockedOutLabel" Content="" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="20,178,0,0" Width="280" Visibility="Hidden"/>
        <Label Name="ADPasswordLastSetLabel" Content="" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="20,219,0,0" Width="280" Visibility="Hidden"/>
        <Label Name="StatusLabel" Content="" HorizontalAlignment="Left" VerticalAlignment="Top" Margin="100,260,0,0" Width="200"/>
        <Button Name="ResetPasswordButton" HorizontalAlignment="Left" VerticalAlignment="Top" Width="75" Margin="100,300,0,0" Height="50" Visibility="Hidden">
            <TextBlock TextWrapping="Wrap" TextAlignment="Center">Reset Password</TextBlock>
        </Button>
        <Button Name="UnlockAccountButton" VerticalAlignment="Top" Margin="0,300,100,0" Padding="1" HorizontalAlignment="Right" Width="75" Height="50" Visibility="Hidden">
            <TextBlock TextWrapping="Wrap" TextAlignment="Center">Unlock Account</TextBlock>
        </Button>
    </Grid>
</Window>
'@
$form = [System.Windows.Markup.XamlReader]::Load([System.Xml.XmlNodeReader]::new($xaml))
foreach ($control in $xaml.SelectNodes('//*[@Name]'))
{
    Write-Verbose "Assigning control: $($control.Name)."
    Set-Variable -Name $control.Name -Value $form.FindName($control.Name) -Scope global -Force
}
Write-Verbose 'WPF XAML initialized.'
#endregion

#region Event handler setup
function Reset-Form
{
    $ADNameLabel.Visibility = [System.Windows.Visibility]::Hidden
    $ADNameLabel.Content = ''
    $ADEnabledLabel.Visibility = [System.Windows.Visibility]::Hidden
    $ADEnabledLabel.Content = ''
    $ADLockedOutLabel.Visibility = [System.Windows.Visibility]::Hidden
    $ADLockedOutLabel.Content = ''
    $ADPasswordLastSetLabel.Visibility = [System.Windows.Visibility]::Hidden
    $ADPasswordLastSetLabel.Content = ''
    $ResetPasswordButton.Visibility = [System.Windows.Visibility]::Hidden
    $UnlockAccountButton.Visibility = [System.Windows.Visibility]::Hidden
    $StatusLabel.Content = ''
    $SearchButton.IsEnabled = $false
}

$UsernameTextBox.Add_TextChanged({
    $SearchButton.IsEnabled = -not [string]::IsNullOrWhiteSpace($UsernameTextBox.Text)
})

$ClearButton.Add_Click({
    Reset-Form
    $UsernameTextBox.Text = ''
})

$SearchButton.Add_Click({
    $global:user = $null
    Reset-Form

    $getAdUserArgs = @{
        'Identity'    = $UsernameTextBox.Text.Trim()
        'Properties'  = @('Name', 'Enabled', 'LockedOut', 'PasswordLastSet')
        'ErrorAction' = [ActionPreference]::Ignore
    }
    $global:user = Get-ADUser @getAdUserArgs

    if (-not $user)
    {
        $StatusLabel.Foreground = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.Color]::FromRgb(255, 0, 0)
        )
        $StatusLabel.Content = 'Failed to find user: ' + $getAdUserArgs['Identity']
        return
    }

    $ADNameLabel.Content = 'Name: ' + $global:user.Name
    $ADNameLabel.Visibility = [System.Windows.Visibility]::Visible

    $ADEnabledLabel.Content = 'Enabled: ' + $global:user.Enabled
    $ADEnabledLabel.Visibility = [System.Windows.Visibility]::Visible

    $ADLockedOutLabel.Content = 'Locked out: ' + $global:user.LockedOut
    $ADLockedOutLabel.Visibility = [System.Windows.Visibility]::Visible

    $ADPasswordLastSetLabel.Content = 'Password last reset: ' + $global:user.PasswordLastSet
    $ADPasswordLastSetLabel.Visibility = [System.Windows.Visibility]::Visible

    $ResetPasswordButton.Visibility = [System.Windows.Visibility]::Visible
    $UnlockAccountButton.Visibility = [System.Windows.Visibility]::Visible
})

$ResetPasswordButton.Add_Click({
    try
    {
        $global:user | Set-ADAccountPassword -NewPassword $Credential.Password -ErrorAction Stop
        $global:user | Set-ADUser -ChangePasswordAtLogon $true -ErrorAction Stop
        $StatusLabel.Foreground = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.Color]::FromRgb(0, 255, 0)
        )
        $StatusLabel.Content = 'Account password has been reset.'
    }
    catch
    {
        $StatusLabel.Foreground = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.Color]::FromRgb(255, 0, 0)
        )
        $StatusLabel.Content = "Failed to reset account password: $PSItem"
    }
})

$UnlockAccountButton.Add_Click({
    try
    {
        $global:user | Unlock-ADAccount -ErrorAction Stop
        $StatusLabel.Foreground = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.Color]::FromRgb(0, 255, 0)
        )
        $StatusLabel.Content = 'Account has been unlocked.'
    }
    catch
    {
        $StatusLabel.Foreground = [System.Windows.Media.SolidColorBrush]::new(
            [System.Windows.Media.Color]::FromRgb(255, 0, 0)
        )
        $StatusLabel.Content = "Failed to unlock account: $PSItem"
    }
})
#endregion

#region Run the application
$null = $SW::ShowWindow($hWnd, $SW_HIDE)
$app.Run($form)
#endregion
