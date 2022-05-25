#11 November 2011
#ExecFsx.ps1
#Onorio Catenacci

#Insure we get all the error checking from Powershell itself that we can
set-strictmode -version latest

#Set this to point at the location of fsi.exe on your machine.
set-variable -name fsi -value """$env:ProgramFiles\Microsoft F#\v4.0\fsi.exe""" -option constant
#This is where I put all of my .fsx files. Change this to your favorite location
set-variable -name FSharpScriptHome -value "$env:HomeDrive$env:HomePath\My Documents\FSharpHacks" -option constant

function ExecuteFSharpShellScript ([string] $scriptName)
{
   start-process $fsi -argumentlist "--exec ""$FSharpScriptHome\$scriptName""" 
}

#Example: .\ExecFsx.ps1 Build.fsx
ExecuteFSharpShellScript($args[0])