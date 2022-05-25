#   ****************************************************************************
#   TUTORIAL PowerShell:   Basic Operations
#   ****************************************************************************

<#
    PSH Basics
        :01     variables (special constants)
        :02     alias
        :03     script name
        :04     PWD and show Environment
        :05     change path
        :06     test path
        :07     powerShell Drive
        :08     show power shell version
        :09     show the loaded functions
        :10     show ENV:module path
        :11     show modules
        :12     show snapins
        :13     show commands
        :14     get-help
#>

#
#   =*= :   include my library
#

$v_SCP = $MyInvocation.MyCommand.Name

$sDir = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
try {
    $sMyTutorialLib = 'TUT.inc.ps1'; . ("$sDir\$sMyTutorialLib") ($v_SCP) # call
}
catch {
    Write-Host "??? error while loading : <$sMyTutorialLib>"
    return
}

#
#   =*= :   load my header - start logging
#

$l=__LINE__; f_lib_header($l)

#
#   =*= :   show content
#

Write-Host ""   # 1 extra line
Write-Host @"
=== :   PSH Basics
        :01     variables
        :02     alias : new,set,get,Remove-Item,export,import
        :03     show script name
        :04     show my PWD and Environment Variables
        :05     change path
        :06     test path
        :07     powerShell Drive
        :08     show power shell version
        :09     show the loaded functions
        :10     show ENV:module path
        :11     show modules
        :12     show snapins
        :13     show commands
        :14     get-help
"@

#
#   =*= :01 variables   (x1:cfg,x2:auto,x3:user)
#

$v_LINE=__LINE__; f_lib_menu("variables")(__LINE__)

<#  === configuration variables
    �   $ConfirmPreference              = High
    �   $DebugPreference                = SilentlyContinue
    �   $ErrorActionPreference          = Continue
    �   $ErrorView                      = NormalView
    �   $FormatEnumerationLimit         = 4
    �   $InformationPreference          = SilentlyContinue
    �   $LogCommandHealthEvent          = False (not logged)
    �   $LogCommandLifecycleEvent       = False (not logged)
    �   $LogEngineHealthEvent           = True (logged)
    �   $LogEngineLifecycleEvent        = True (logged)
    �   $LogProviderLifecycleEvent      = True (logged)
    �   $LogProviderHealthEvent         = True (logged)
    �   $MaximumAliasCount              = 4096
    �   $MaximumDriveCount              = 4096
    �   $MaximumErrorCount              = 256
    �   $MaximumFunctionCount           = 4096
    �   $MaximumHistoryCount            = 4096
    �   $MaximumVariableCount           = 4096
    �   $OFS                            = (Space character (" "))
    �   $OutputEncoding                 = ASCIIEncoding object
    �   $ProgressPreference             = Continue
    �   $PSDefaultParameterValues       = (None - empty hash table)
    �   $PSEmailServer                  = (None)
    �   $PSModuleAutoLoadingPreference  = All
    �   $PSSessionApplicationName       = WSMAN
    �   $PSSessionConfigurationName     = http://schemas.microsoft.com/PowerShell/microsoft.PowerShell
    �   $PSSessionOption                = (See below)
    �   $VerbosePreference              = SilentlyContinue
    �   $WarningPreference              = Continue
    �   $WhatIfPreference               = 0
#>

#   use a short alias
Set-Alias wh Write-Host

#
#   =** x1: config-variables
#

f_lib_text('show predefined configuartion variables')(__LINE__)

wh '    $ConfirmPreference              :=  <'  $ConfirmPreference  '>'
wh '    $DebugPreference                :=  <'  $DebugPreference               '>'
wh '    $ErrorActionPreference          :=  <'  $ErrorActionPreference         '>'
wh '    $ErrorView                      :=  <'  $ErrorView                     '>'
wh '    $FormatEnumerationLimit         :=  <'  $FormatEnumerationLimit        '>'
wh '    $InformationPreference          :=  <'  $InformationPreference         '>'
wh '    $LogCommandHealthEvent          :=  <'  $LogCommandHealthEvent         '>'
wh '    $LogCommandLifecycleEvent       :=  <'  $LogCommandLifecycleEvent      '>'
wh '    $LogEngineHealthEvent           :=  <'  $LogEngineHealthEvent          '>'
wh '    $LogEngineLifecycleEvent        :=  <'  $LogEngineLifecycleEvent       '>'
wh '    $LogProviderLifecycleEvent      :=  <'  $LogProviderLifecycleEvent     '>'
wh '    $LogProviderHealthEvent         :=  <'  $LogProviderHealthEvent        '>'
wh '    $MaximumAliasCount              :=  <'  $MaximumAliasCount             '>'
wh '    $MaximumDriveCount              :=  <'  $MaximumDriveCount             '>'
wh '    $MaximumErrorCount              :=  <'  $MaximumErrorCount             '>'
wh '    $MaximumFunctionCount           :=  <'  $MaximumFunctionCount          '>'
wh '    $MaximumHistoryCount            :=  <'  $MaximumHistoryCount           '>'
wh '    $MaximumVariableCount           :=  <'  $MaximumVariableCount          '>'
wh '    $OFS                            :=  <'  $OFS                           '>'
wh '    $OutputEncoding                 :=  <'  $OutputEncoding                '>'
wh '    $ProgressPreference             :=  <'  $ProgressPreference            '>'
wh '    $PSDefaultParameterValues       :=  <'  $PSDefaultParameterValues      '>'
wh '    $PSEmailServer                  :=  <'  $PSEmailServer                 '>'
wh '    $PSModuleAutoLoadingPreference  :=  <'  $PSModuleAutoLoadingPreference '>'
wh '    $PSSessionApplicationName       :=  <'  $PSSessionApplicationName      '>'
wh '    $PSSessionConfigurationName     :=  <'  $PSSessionConfigurationName    '>'
wh '    $PSSessionOption                :=  <'  $PSSessionOption               '>'
wh '    $VerbosePreference              :=  <'  $VerbosePreference             '>'
wh '    $WarningPreference              :=  <'  $WarningPreference             '>'
wh '    $WhatIfPreference               :=  <'  $WhatIfPreference              '>'

#
#   =** x2: auto-variables
#

f_lib_text('auto-variables')(__LINE__)

wh '    $               :=  <'  $  '>'               # script name
wh '    ?               :=  <'  ?  '>'               # state of last ..
wh '    $?              :=  <'  $?  '>'              # state of last operation
wh '    $HOME           :=  <'  $HOME  '>'           # homeDir
wh '    $PSHOME         :=  <'  $PSHOME  '>'         # home of powershell
wh '    $PID            :=  <'  $PID  '>'            # process id
wh '    $PSCulture      :=  <'  $PSCulture  '>'      # de-DE
wh '    PSScriptRoot    :=  <'  $PSScriptRoot '>'    # root
wh '    PSCommandPath   :=  <'  $PSCommandPath  '>'  # comand-path of PSH
wh '    $true           :=  <'  $true  '>'             # true
wh '    $false          :=  <'  $false '>'             # false
wh '    $null           :=  <'  $null '>'           # ''

$e = $Error[0]                      # Error[0]:last errors, Error[1]:error before
$n = $Error[0].length               # '1'
wh '    $Error[0].len   :=  <' $n  '>'

#
#   =*= :   using my variables
#

$bAssertSilentMode = $true  # no exit at assert

#
#   =** clean
#
<#  --- produces errors
    Remove-Item -path "alias:\a_Name1"
    Remove-Variable -name i -force
    Remove-Variable C_MYPI -force
#>

$Error.clear()
f_lib_assert(__LINE__)($bAssertSilentMode)   # !CRQ-200414:assert:=silent

#
#   =** x3: user-variables
#

f_lib_text('user-variables')

New-Variable -name i -value 5;  wh "*   New-Variable i:=<$i>"

wh "*   Get-Variable i"
Get-Variable -name i;           # shows <$i>"

wh "*   remove"
Remove-Variable -name i;        wh "*   Remove-Variable i"
New-Variable -name i -value 2;  wh "*   New-Variable i:=<$i>"
puts "i=<$i>"

#   check
f_lib_assert (__LINE__)($bAssertSilentMode)


#   only clean
wh "*   clear"
Clear-Variable -name i
puts "i=<$i>"

#   set and clear
$i=77;  puts "i=<$i>"
wh "*   set to NULL"
$i = $null; puts "i=<$i>"

#   set a variable - 2 ways
Set-Variable -name i -value 123;    wh "*   Set-Variable i:=<$i>"
$n=4711; $i=$n; wh "*   i:=<$n> => i=<$i>"

#   constant
New-Variable -name C_MYPI -value 3.14 -option constant
f_lib_assert(__LINE__)($bAssertSilentMode)
wh "*   constant myPi:=<$C_MYPI>"


f_lib_text('show all variables')(__LINE__)

#   show all variables about PS-Provider
$x = Get-ChildItem -Path variable:
$aVar = $x.name
puts "$aVar"

#
#   =*= :02 alias: new,get,set,remove,export,import
#

$v_LINE=__LINE__; f_lib_menu("Alias...SET+GET")(__LINE__)

#   create a new alias, error if exists
f_lib_text('new alias')
$pAlias = get-alias
New-Alias -name a_Name1  -value "hans"
f_lib_assert(__LINE__)($bAssertSilentMode) # don't stop the script

#   get this alias
f_lib_text('get alias')
$x = get-alias -name a_Name1
$s = $x.Definition
puts "get-alias -name => '$s'"  # !PHA: not $x.Definition

#   set overwrites existing one
f_lib_text('set alias')
Set-Alias -name a_Name1  -value "peter"
Set-Alias a_Name2  "otto"
Set-Alias a_Name3  "willy"  # easy

f_lib_text('get alias:names*')

$x = alias "a_Name*"
$s = $x.Name
puts "alias a_Name* => '$s'"   # !PHA: not $x.Definition

f_lib_text('delete alias Name3')
Remove-Item -Path "Alias:\a_Name3"
f_lib_assert(__LINE__)

$x = alias "a_Name*"
$s = $x.Name
puts "alias a_Name* => '$s'"   # !PHA: not $x.Definition

f_lib_text('export')
$f = $env:tmp + '/TUT-alias.txt'
Export-Alias -Path $f
Write-Host "*** `tDONE: alias export to : '$f'"

sleep 1
f_lib_text('import...')
sleep 1
Write-Host "importing '$f'"
$f = $env:tmp + '/TUT-alias.txt'
Import-Alias -Path $f -Force
Write-Host "*** `tDONE: alias import from : '$f'"

#
#   =*= :03 show script name
#

$sScriptName1 =  $MyInvocation.ScriptName
$sScriptName2 =  $MyInvocation.MyCommand.Name            # without path
$sScriptName3 =  $MyInvocation.MyCommand.Definition      # includes path

$v_LINE=__LINE__; f_lib_menu("script name")
puts "sScriptName1:=<$sScriptName1>"    # empty
puts "sScriptName2:=<$sScriptName2>"    # this script without path
puts "sScriptName3:=<$sScriptName3>"    # this script including path


#
#   =*= :04 show my PWD
#

$v_LINE=__LINE__; f_lib_menu("show PWD")

#   3 ways
$sDir = pwd; puts "pwd  `t=> PWD1:=<$sDir>"
$sDir = Get-Location; puts "Get-Location `t=> PWD2:=<$sDir>"
$sDir = Convert-Path .\; puts "Convert-Path `t=> PWD3:=<$sDir>"
f_lib_assert(__LINE__)

#
#   =*= :04b show my Environment variables !CRQ-200414:showEnv
#

$l=__LINE__; f_lib_menu("show Environment")($l)
gci env:* | Sort-Object Name  | Format-Table Name,Value  # gci:=Get-ChildItem

#
#   =*= :05 change path     :   cmd:="Set-Location"
#

$v_LINE=__LINE__; f_lib_menu("change path")

f_lib_text('set pwd')(__LINE__)
$sPwd = pwd
Set-Location $env:tmp   # ALIAS:=gci
$sDir = Get-Location; puts "set-location1 `t=> DIR:=<$sDir>"
Set-Location $sPwd

f_lib_text('get loc')
$sDir = Get-Location; puts "set-location2 `t=> DIR:=<$sDir>"

#   the alias cd is set to "Set-Location"
f_lib_text('alias')(__LINE__)
$x = alias cd
wh "alias cd:= '" $x.Definition "'"
f_lib_assert(__LINE__)

#
#   =*= :06 test path           :cmd:="test-path"
#
f_lib_trace("testPath")(__LINE__)

$v_LINE=__LINE__; f_lib_menu("test path")(__LINE__)
$sDir   = pwd
$bRc    = test-path $sDir
puts "test-path1('$sDir') `t=> bRc:=<$bRc>"
$sDir   = 'otto'
$bRc    = test-path $sDir
puts "test-path2('$sDir') `t=> bRc:=<$bRc>"
f_lib_assert(__LINE__)

#
#   =*= :07 powerShell Drive    :cmd:="get-psDrive"
#

$v_LINE=__LINE__; f_lib_menu("pshell drives")(__LINE__)

f_lib_text("get-psDrive...")(__LINE__)

$aPsDrive = get-psDrive
f_lib_putA $aPsDrive

#   we change the psdrive to Alias:
$pLocation  = Get-Location   # saveIt
$pNewLoc    = "Alias:"

f_lib_text("Set-Location:=<'$pNewLoc'>")
Set-Location "alias:"

#   we show our alias "+..."
$v = "a_name1"
f_lib_text("Get-ChildItem:=<'$v'>")
$x = Get-ChildItem -path $v
$x = $x.DisplayName
puts "dipslayName:='$x'"

#   go back
Set-Location $pLocation
f_lib_assert(__LINE__)

#
#   =*= :08 show power shell version    :cmd:="get-host"
#

f_lib_menu("PowerShell Version...")(__LINE__)
$x = get-host
$s = $x.Version
Write-Host "VERSION:=<$s>"

#
#   =*= :09 show the loaded functions   :cmd:="Get-Command"
#

f_lib_menu("show loaded functions")(__LINE__)
$sFct = "f_lib_*"
puts "Get-Command($sFct)..."
$x = Get-Command $sFct
$s = $x.name
puts "FCT:=<$s>"
f_lib_assert(__LINE__)

#
#   =*= :10 show ENV:module path        :cmd:="Get-Content"
#

f_lib_menu("show ModulePath")(__LINE__)
$sModulePath = Get-Content Env:PSModulePath
puts "sModulePath:=<$sModulePath>"
f_lib_assert(__LINE__)

#
#   =*= :11 show modules                :cmd:="Get-Module"
#

f_lib_menu("show loaded modules")(__LINE__)

#   loaded
$x = Get-Module
#   $x = Get-Module -ListAvailable  # available, take long time
$a = $x.Name
puts $a
f_lib_assert(__LINE__)

#
#   =*= :12 show snapins                :cmd:="Get-Module"
#

f_lib_menu("show snapins")(__LINE__)
$x = get-PsSnapin
$a = $x.Name
puts $a
f_lib_assert(__LINE__)($bAssertSilentMode)

#
#   =*= :13 show commands               :cmd:="Get-Command"
#

f_lib_menu("commands")(__LINE__)
$x = Get-Command wa*
$x = $x.name
f_lib_putA $x
f_lib_assert(__LINE__)

#
#   =*= :14 get help info               :cmd:="get-help"
#

f_lib_menu("helpInfo")(__LINE__)

$x = get-help get-PsSnapin
$x = $x.Synopsis

f_lib_text("get-help get-PsSnapin:...")(__LINE__)
puts $x
f_lib_assert(__LINE__)

#
#   =*= :   mod!: FOOTER
#

#   f_bug(__LINE__)
$l=__LINE__; f_lib_footer($l)
