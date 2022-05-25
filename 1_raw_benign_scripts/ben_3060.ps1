# The default is High. Setting it here for clarity.
# https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_preference_variables?view=powershell-5.1
$ConfirmPreference = 'High'

[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [switch]$Force
)

# Use this to prompt the user by default. Use -Force to disable prompting. 
# NOTE: that you have to add the $Force parameter yourself, as shown above. It doesn't even have to be 
# named $force. How you implement this is up to you.
if ($Force -or $PSCmdlet.ShouldContinue("Some resource", "Would you like to continue?") ) {
  Write-Host "If you're reading this, you either passed in `$Force or typed 'Y' when prompted." -ForegroundColor Red
} 

# Use this to NOT prompt by default. Use -Confirm to enable prompting. Or, use the -WhatIf option to 
# print to console the anticipated outcome of running this block - without actually running it.
# NOTE: Both -Confirm and -Whatif are common PS parameters. You don't need to implemented them like $Force was above. 
if ($PSCmdlet.ShouldProcess("Some other resource", "Would you like to process?") ) {
  Write-Host 'This will always run UNLESS the -Confirm or -Whatif option is used.' -ForegroundColor Red
} 