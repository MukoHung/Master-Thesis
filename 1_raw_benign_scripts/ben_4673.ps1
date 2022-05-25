<#
    =!= TUTORIAL PowerShell: variable scope

    !URL: https://www.windowspro.de/script/
            ~gueltigkeitsbereich-scope-von-variablen-powershell

    usage:
        callMe:
                PSH><script.ps1>
                NOT PSH>. script.ps1 - this exports always
    REM:
        !URL:
        https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core
        /about/about_scopes?view=powershell-6
        Das Konzept der G�ltigkeits�bereiche trifft in PowerShell nicht
        nur auf Variablen zu, sondern auch auf Aliase,
        Funktionen und PowerShell Drives.


    variable scope usage:
        �   standard :  copy,   noModify
        �   global  :   copy,   modify
        �   local   :   copy,   noModify == 'standard'
        �   private :   noCopy, noModify
        �   script  :   copy,   modify
#>
<#
    !URL: https://docs.microsoft.com/en-us/powershell/module/
            microsoft.powershell.core/about/about_scopes?view=powershell-6

        �   Global:
            The scope that is in effect when PowerShell starts.
            Variables and functions that are present when PowerShell
            starts have been created in the global scope,
            such as automatic variables and preference variables.
            The variables, aliases, and functions in your
            PowerShell profiles are also created in the global scope.

        �   Script:
            The scope that is created while a script file runs.
            Only the commands in the script run in the script scope.
            To the commands in a script, the script scope is the local scope.

        �   Local:
            The current scope.
            The local scope can be the global scope or any other scope.

        �   Private:
            Items in private scope cannot be seen outside of the current scope.
            You can use private scope to create a private version of
            an item with the same name in another scope.
#>



. .\TUT.inc.ps1 $MyInvocation.MyCommand.Name
$v_SCP  = $MyInvocation.MyCommand.Name


#   header
f_lib_header(__LINE__)

Write-Host ""
Write-Host @"
=== H:  PSH Variable Scope
    `tm:01  script scopes
            standard, local, private, script, global
    `tm:02  reference usage in functions - like pointer
"@

#
#   =*= m:01 script scopes
#

f_lib_menu("script scopes")(__LINE__)
f_lib_putEc

f_lib_text("define in script")(__LINE__)
$v_i0           =   __LINE__    # scope.out|sub:={FALSE,TRUE}
$GLOBAL:v_i1    =   __LINE__    # scope.out|sub:={FALSE,TRUE}
$LOCAL:v_i2     =   __LINE__    # scope.out|sub:={FALSE,TRUE}
$PRIVATE:v_i3   =   __LINE__    # scope.out|sub:={FALSE,FALSE}
$SCRIPT:v_i4    =   __LINE__    # scope.out|sub:={FALSE,TRUE}
puts "DEF: $v_SCP.`$v_i0:=<$v_i0>   ::  std"
puts "DEF: $v_SCP.`$v_i1:=<$v_i1>   ::  glb"
puts "DEF: $v_SCP.`$v_i2:=<$v_i2>   ::  loc"
puts "DEF: $v_SCP.`$v_i3:=<$v_i3>   ::  prv"
puts "DEF: $v_SCP.`$v_i4:=<$v_i4>   ::  scp"

f_lib_trace(__LINE__)(__FUNCTION__) "define globals"

function f_dummy($p_iLoc) {
<#
 #  for the script is that a supscope
 #  outside variables are known?
 #  declare 3 kind of variables
#>
    f_lib_text("in my function")(__LINE__)
    $f = "{0}" -f $MyInvocation.MyCommand
    $i0         = __LINE__              # REM: like 'private'
    $GLOBAL:i1  = __LINE__
    $LOCAL:i2   = __LINE__
    $PRIVATE:i3 = __LINE__
    $SCRIPT:i4  = __LINE__
    puts "DEF :: $f.`$i0:=<$i0> ::  std"
    puts "DEF :: $f.`$i1:=<$i1> ::  glb"
    puts "DEF :: $f.`$i2:=<$i2> ::  loc"
    puts "DEF :: $f.`$i3:=<$i3> ::  prv"
    puts "DEF :: $f.`$i4:=<$i4> ::  scp"
    f_lib_trace(__LINE__)($f) "define locals"

    puts "GET :: $f.`$v_i0 = <$v_i0>"
    puts "GET :: $f.`$v_i1 = <$v_i1>"
    puts "GET :: $f.`$v_i2 = <$v_i2>"
    puts "GET :: $f.`$v_i3 = <$v_i3>"   # <undefined>
    puts "GET :: $f.`$v_i4 = <$v_i4>"
    f_lib_trace(__LINE__)($f)   "show globals in my function"

    $v_i0           = __LINE__              # REM: like 'private'
    $GLOBAL:v_i1    = __LINE__
    $LOCAL:v_i2     = __LINE__
    $PRIVATE:v_i3   = __LINE__
    $SCRIPT:v_i4    = __LINE__
    puts "SET :: $f.`$v_i0 := <$v_i0>"
    puts "SET :: $f.`$v_i1 := <$v_i1>"
    puts "SET :: $f.`$v_i2 := <$v_i2>"
    puts "SET :: $f.`$v_i3 := <$v_i3>"   # <undefined>
    puts "SET :: $f.`$v_i4 := <$v_i4>"
    f_lib_trace(__LINE__)($f) "set the globals"
}
f_dummy(__LINE__)

f_lib_text("back in my script")(__LINE__)
puts "$v_SCP.`$v_i0 = <$v_i0>"  # <old-value>
puts "$v_SCP.`$v_i1 = <$v_i1>"
puts "$v_SCP.`$v_i2 = <$v_i2>"  # <old-value>
puts "$v_SCP.`$v_i3 = <$v_i3>"  # <old-value>
puts "$v_SCP.`$v_i4 = <$v_i4>"
f_lib_trace(__LINE__)(__FUNCTION__) "show globalVars"

puts "$v_SCP.`$i0 = <$i0>"      # <undefined>
puts "$v_SCP.`$i1 = <$i1>"
puts "$v_SCP.`$i2 = <$i2>"
puts "$v_SCP.`$i3 = <$i3>"      # <undefined>
puts "$v_SCP.`$i4= <$i4>"
f_lib_trace(__LINE__)(__FUNCTION__) "show localVars"

#
#   =*= m:02 reference usage in functions
#

f_lib_menu("references or pointer")(__LINE__)

#First create the variables (note you have to set them to something)
$GLOBAL:var1 = $null
$GLOBAL:var2 = $null
$GLOBAL:var3 = $null

#   The type of the reference argument should be of type [REF]
function f_test_add ($a, $b, [REF]$c)
{
    # add $a and $b and set the requested global variable to equal to it
    # Note how you modify the value.
    $c.value = $a + $b
}

#   You can then call it like this:
f_test_add (1) (2) ([REF]$GLOBAL:var3)
puts "$v_SCP.`$c = <$var3>" # var3:='3'

f_lib_footer(__LINE__)
