# Script execution in x86
$env:Processor_Architecture
[IntPtr]::Size #4 in a 32-bit process, and 8 in a 64-bit process
if ($env:Processor_Architecture -ne "x86"){
	write-warning 'Launching x86 PowerShell'
	&"$env:windir\syswow64\windowspowershell\v1.0\powershell.exe" -noninteractive -noprofile -file $myinvocation.Mycommand.path -executionpolicy bypass
	exit
}