<# 
 .EXAMPLE
	PS .\TOOL.ps1
 .NOTES
	Name: Marcus Rosa
	E-mail: mvrosa@outlook.com.br
.LINK
	GitHub: https://github.com/mvrosa   
#>

$directorypath = (Get-Item -Path ".\").FullName
$config = "config\config.txt"
$delete = "$directorypath\reports"

function Show-Menu
{
	param (
		[string]$Title = 'TOOLS'
	)
	Clear-Host
	Write-Host ""  
	Write-Host " + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +"
	Write-Host " "    
	Write-Host "                                             FERRAMENTAS                                          "    
	Write-Host " "    
	Write-Host " + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +"
	Write-Host " "    
	Write-Host "                                   [ 00 ] - CONFIG TOOL"
	Write-Host "                                   [ 01 ] - SYNC DE HORARIO"
	Write-Host "                                   [ 02 ] - COPIA CONFIG JAVA"
	Write-Host "                                   [ 03 ] - LIMPEZA DE TEMPS"
	Write-Host "                                   [ 04 ] - INGRESSAR MAQUINA NO DOMINIO" 
	Write-Host "                                   [ 05 ] - LOGOFF SERVERS" 
	Write-Host "                                   [ 06 ] - USUARIOS ATIVOS NO AD" 
	Write-Host "                                   [ 07 ] - RELATORIO DE ACESSO AO TS" 
	Write-Host "                                   [ 08 ] - DELTA CURITIBA OFFICE365"
	Write-Host "                                   [ 09 ] - RELATORIO DE PROXYADDRESS" 
	Write-Host "                                   [ 10 ] - EXPORTAR GRUPOS DO USUARIO > TXT" 
	Write-Host "                                   [ 11 ] - EXPORTAR MEMBROS DO GRUPO > TXT" 
	Write-Host "                                   [ 12 ] - REBOOT" 
	Write-Host "                                   [ 50 ] - EXCLUIR RELATORIOS"  
	Write-Host "                                   [ 99 ] - EXIT"
	Write-Host ""	 
	Write-Host " + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +"
	Write-Host ""  
}
do
{
	Show-Menu
	$menu = Read-Host -Prompt "Entre com o numero"
	switch ($menu)
	{ '00' {
	Clear-Host
	Invoke-Item $directorypath\$config
	} '01' {
	Clear-Host
	$pc = Read-Host -Prompt "Insira o IP da maquina"
	PsExec.exe -s \\$pc net time \\srvsp-ad2 /set /y
	} '02' {
	Clear-Host
	.\java_exception_sites.ps1
	} '03' {
	Clear-Host
	#PowerShell.exe -NoProfile -ExecutionPolicy Bypass -Command "& {Start-Process PowerShell.exe -ArgumentList '-NoProfile -ExecutionPolicy Bypass -File ""C:\Scripts\Limpeza_v1.ps1""' -Verb RunAs}"
	.\Clean_temp_files.ps1
	} '04' {
	Clear-Host
	.\maquina_dominio.ps1
	} '05' {
	Clear-Host
	.\Logoff.ps1
	} '06' {
	Clear-Host
	.\ad-users.ps1
	} '07' {
	Clear-Host
	.\relatorio_rdp_TS1.ps1
	.\relatorio_rdp_TS7.ps1
	.\relatorio_rdp_TS8.ps1
	.\relatorio_rdp_TS9.ps1
	.\relatorio_rdp_TS10.ps1
	} '08' {
	Clear-Host
	Invoke-Command -ScriptBlock { Start-ADSyncSyncCycle -PolicyType delta } -ComputerName HOSTNAME
	} '09' {
	Clear-Host
	.\proxyaddress.ps1
	} '10' {
	Clear-Host
	$username = Read-Host -Prompt "Nome do usuario"
	Get-ADPrincipalGroupMembership $username | Select-Object SamAccountName | Out-File "c:\TEMP\$username.txt" -Encoding utf8
	} '11' {
	Clear-Host
	$groupmember = Read-Host -Prompt "Nome do grupo"
	Get-ADGroupMember $groupmember | Select-Object SamAccountName | Out-File "c:\TEMP\$groupmember.txt" -Encoding utf8
	} '12' {
	Clear-Host
	$pcname = Read-Host -Prompt "Nome ou IP da maquina"
	Restart-Computer -ComputerName $pcname -Force
    } '50' {
	Clear-Host
	Remove-Item $delete\ad-users\* -Recurse -Force
	Remove-Item $delete\relatorio_TS\* -Recurse -Force
	Remove-Item $delete\proxyaddress\* -Recurse -Force
	} '99' {
     return
		}
    }
    Write-Host ""  
    Write-Host " + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +"
    Write-Host " "    
    Write-Host "                                       EXECUTADO COM SUCESSO!"    
    Write-Host " "    
    Write-Host " + - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - +"
    Write-Host " "    
	pause
}
until ($input -eq '99')
