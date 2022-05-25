$inputXML2 = @"
<Window x:Class="EnrollmentMenu.MainWindow"
        xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
        xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
        xmlns:local="clr-namespace:EnrollmentMenu"
        mc:Ignorable="d"
        Title="Completed Changes" Height="350" Width="800">
    <Window.Resources>
        <Style TargetType="ListViewItem">
            <Setter Property="Height" Value="20"/>
        </Style>
    </Window.Resources>
    <Grid>
        <ListView x:Name="listView1" Margin="10,77,12,10">
            <ListView.View>
                <GridView AllowsColumnReorder="False">
                    <GridViewColumn Header="File" DisplayMemberBinding ="{Binding 'FileName'}" Width="420"/>
                    <GridViewColumn Header="Changes" DisplayMemberBinding ="{Binding 'TheChanges'}"/>
                </GridView>
            </ListView.View>
        </ListView>
        <Image x:Name="image" HorizontalAlignment="Left" Height="39" Margin="10,10,0,0" VerticalAlignment="Top" Width="111" Source="C:\Users\showlett\Pictures\Small Logo.jpg"/>
        <Button x:Name="button" Content="Close" HorizontalAlignment="Left" Margin="687,10,0,0" VerticalAlignment="Top" Width="75"/>
        <Label x:Name="label" Content="Double Click to Open File Location&#xA;" HorizontalAlignment="Center" Margin="186,10,250,0" VerticalAlignment="Top" Width="356" FontSize="20" Height="35" FontFamily="Verdana"/>
    </Grid>
</Window>

"@       

 
$inputXML2 = $inputXML2 -replace 'mc:Ignorable="d"','' -replace "x:N",'N'  -replace '^<Win.*', '<Window'
 
[void][System.Reflection.Assembly]::LoadWithPartialName('presentationframework')
[xml]$XAML = $inputXML2
#Read XAML
 
    $reader=(New-Object System.Xml.XmlNodeReader $XAML)
  try{$Form=[Windows.Markup.XamlReader]::Load( $reader )}
catch{Write-Verbose "Unable to load Windows.Markup.XamlReader. Double-check syntax and ensure .net is installed."}
 
#===========================================================================
# Load XAML Objects In PowerShell
#===========================================================================
 
$xaml.SelectNodes("//*[@Name]") | %{Set-Variable -Name "WPF$($_.Name)" -Value $Form.FindName($_.Name)}
 
Function Get-FormVariables{
if ($global:ReadmeDisplay -ne $true){Write-Verbose "If you need to reference this display again, run Get-FormVariables" -ForegroundColor Yellow;$global:ReadmeDisplay=$true}
Write-Verbose "Found the following interactable elements from our form" -ForegroundColor Cyan
get-variable WPF*
}

$WPFbutton.Add_Click({$form.Close()})
$WPFimage.Source = [System.Convert]::FromBase64String('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
')

$Form.Add_MouseDoubleClick({
    Invoke-Item $WPFlistView1.SelectedItem.destination
})


$runFiles | % {$WPFlistView1.AddChild($_)}

$sc= {
	$col = "TheChanges"
	$view = $WPFlistView1.Items
	$view.SortDescriptions.Clear()

    if ($script:sort -eq 'descending'){
        $sortDescription = New-Object System.ComponentModel.SortDescription($col,'Ascending')
        $script:sort = 'ascending'
    }
    ElseIf ($script:sort -eq 'ascending')  {
        $sortDescription = New-Object System.ComponentModel.SortDescription($col,'Descending')
        $script:sort = 'descending'
    }
    Else {
        $sortDescription = New-Object System.ComponentModel.SortDescription($col,'Ascending')
        $script:sort = 'ascending' 
    } 

	$view.SortDescriptions.Add($sortDescription)

}

$evt = [Windows.RoutedEventHandler]$sc
$WPFlistView1.AddHandler([System.Windows.Controls.GridViewColumnHeader]::ClickEvent, $evt)

$Form.ShowDialog() | out-null