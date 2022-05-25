#REQUIRES -Version 3.0

# This is a simple sample for access the MS UIAutomation in PowerShell. 
# In this sample:
#  1. Load the MS UIA via System.Reflection.Assembly
#  2. Launch the AUT ( calc.exe )
#  3. Find the AutomationElement via the AUT Process Id
#  4. Find buttons via 'ClassName' and 'Name' property
#  5. Click the '1', '+', '1', '=' buttons. 
# At last, we will get '2' in the result of calc App.

# Load MS UIAutomation assemblies
Write-Host "Loading MS UIA assemblies"
[void][System.Reflection.Assembly]::LoadWithPartialName("UIAutomationClient")
[void][System.Reflection.Assembly]::LoadWithPartialName("UIAutomationTypes")
[void][System.Reflection.Assembly]::LoadWithPartialName("UIAutomationProvider")
[void][System.Reflection.Assembly]::LoadWithPartialName("UIAutomationClientsideProviders")


# Register client side provider
Write-Host "Register client-side provider"
$client = [System.Reflection.Assembly]::LoadWithPartialName("UIAutomationClientsideProviders")
[Windows.Automation.ClientSettings]::RegisterClientSideProviderAssembly($client.GetName())

# Launch the AUT ( calc.exe ) & sleep 10 seconds for wait the process start
Write-Host "Launching the AUT"
$autProc =  Start-Process calc -PassThru
Start-Sleep -s 10

# Find the calc Element via the process Id
Write-Host "Searching the AUT Root element"
$rootElement = [Windows.Automation.AutomationElement]::RootElement
$condAUTProc = New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::ProcessIdProperty, $autProc.Id)
$autElement = $rootElement.FindFirst([Windows.Automation.TreeScope]::Children, $condAUTProc)

# Find the buttons '1', '+', '='
Write-Host "Searching the button elements"
$condBtn = New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::ClassNameProperty, "Button")

$condName = New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::NameProperty, "1")
$condTarget = New-Object Windows.Automation.AndCondition($condBtn, $condName)
$btn1Element = $autElement.FindFirst([Windows.Automation.TreeScope]::Descendants, $condTarget)

$condName = New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::NameProperty, "+")
$condTarget = New-Object Windows.Automation.AndCondition($condBtn, $condName)
$btnPlusElement = $autElement.FindFirst([Windows.Automation.TreeScope]::Descendants, $condTarget)

$condName = New-Object Windows.Automation.PropertyCondition([Windows.Automation.AutomationElement]::NameProperty, "=")
$condTarget = New-Object Windows.Automation.AndCondition($condBtn, $condName)
$btnEqualElement = $autElement.FindFirst([Windows.Automation.TreeScope]::Descendants, $condTarget)

# Click the buttons
Write-Host "Clicking the buttons"
$btn1Element.GetCurrentPattern([Windows.Automation.InvokePattern]::Pattern).Invoke()
Start-Sleep -s 1
$btnPlusElement.GetCurrentPattern([Windows.Automation.InvokePattern]::Pattern).Invoke()
Start-Sleep -s 1
$btn1Element.GetCurrentPattern([Windows.Automation.InvokePattern]::Pattern).Invoke()
Start-Sleep -s 1
$btnEqualElement.GetCurrentPattern([Windows.Automation.InvokePattern]::Pattern).Invoke()
Start-Sleep -s 1

Write-Host "Finished. Please check the results on the AUT."
