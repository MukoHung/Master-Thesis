<#
Instala/Atualiza o perfil PS para o usu�rio apenas

#>


<#
.Synopsis
    Exibe janela pedindo confirma��o Sim/N�o do operador
.DESCRIPTION
   Apresenta mensagem pedindo Sim/N�o como resposta
#>
function Get-BoolUserChoice
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Descri��o da ajuda de par�m1
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=0)]
        [string] $WindowTile,
        # Descri��o da ajuda de par�m2
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true,Position=1)]
        [string] $WindowMessage, 

        [Parameter(Mandatory=$False, ValueFromPipelineByPropertyName=$true,Position=2)]
        [int] $DefaultAnswer 
    )

    $yes = New-Object System.Management.Automation.Host.ChoiceDescription "&Sim", "Sim"
    $no = New-Object System.Management.Automation.Host.ChoiceDescription "&N�o", "N�o"
    $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
    if( !$DefaultAnswer ){
        return $host.ui.PromptForChoice($WindowTile, $WindowMessage, $options, $DefaultAnswer )
    }else{
        return $host.ui.PromptForChoice($WindowTile, $WindowMessage, $options, 0 )
    }
}

<#
.Synopsis
   Atualiza o perfil pelo arquivo passado
.DESCRIPTION
   Recebe o caminho completo dos arquivos a serem copiados de/para ap�s exibir confirma��o do operador da atualiza��o
#>
function Set-NewProfile
{
    [CmdletBinding()]
    [Alias()]
    [OutputType([int])]
    Param
    (
        # Descri��o da ajuda de par�m1
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=0)]
        [string] $Source,

        # Descri��o da ajuda de par�m2
        [Parameter(Mandatory=$true, ValueFromPipelineByPropertyName=$true, Position=1)]
        [string] $Dest,

        #Necessita confirma��o
        [Parameter(Mandatory=$false, ValueFromPipelineByPropertyName=$true, Position=2)]
        [Switch] $Confirm

    )
    if( Get-BoolUserChoice  ){

    }
}

function scriptRoot{ 
    [OutputType([String])] 
    param()  
    return [string] (Split-Path $MyInvocation.ScriptName -Parent)
}

function Get-DestProfiles(){
    $locTable=@( 
        @("%windir%\system32\WindowsPowerShell\v1.0\profile.ps1", "This profile applies to all users and all shells", $false),
        @("%windir%\system32\WindowsPowerShell\v1.0\ Microsoft.PowerShell_profile.ps1", "This profile applies to all users, but only to the Microsoft.PowerShell shell.", $false),
        @("%UserProfile%\Documentos\WindowsPowerShell\profile.ps1", "This profile applies only to the current user, but affects all shells.", $false),
        @("%UserProfile%\Documentos\WindowsPowerShell\Microsoft.PowerShell_profile.ps1", "This profile applies only to the current user and the Microsoft.PowerShell shell.", $false),
        @("%UserProfile%\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1", "Apenas para a extens�o do Visual Studio 2015", $false)
    )
    $line=1
    $masterChoice=Get-BoolUserChoice -WindowTile "Todos os perfis?" -WindowMessage "Deseja atualizar todos os perfis para todos os Shells existentes?" -DefaultAnswer 1
    if( $masterChoice -eq 0 ){

    }else{

    }
    Write-Host "Escolha quais Perfis ser�o atualizados"
    foreach ($item in $locTable){        
        Write-Host $line") "($item.get(0))"=>"($item.get(1))
        Set-NewProfile -Source "1" -Dest "2" 

        #Read-Host "Deseja instalar neste camimho?" 
        #$tmp = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")        
        #$tmp = ( [Console]::ReadKey )
        #$item.set(2)=( $tmp -eq 'S' )
        

        $line++
    }uuuuu


    Write-Host "Escolha quais Perfis ser�o atualizados(separados por ',':<ENTER = Todos>"
    Write-Host "1 - %windir%\system32\WindowsPowerShell\v1.0\profile.ps1 -> This profile applies to all users and all shells"
    Write-Host "2 - %windir%\system32\WindowsPowerShell\v1.0\ Microsoft.PowerShell_profile.ps1 -> This profile applies to all users, but only to the Microsoft.PowerShell shell."
    Write-Host "3 - %UserProfile%\Documentos\WindowsPowerShell\profile.ps1 -> This profile applies only to the current user, but affects all shells."
    Write-Host "4 - %UserProfile%\Documentos\WindowsPowerShell\Microsoft.PowerShell_profile.ps1 -> This profile applies only to the current user and the Microsoft.PowerShell shell."
    Write-Host "5 - %UserProfile%\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1 -> Apenas para a extens�o do Visual Studio 2015"
    $ret = Read-Host "Op��es"
    if( $ret.Equals("") ){
        $ret = "1,2,3,4,5"
    }
    $ret = $ret.Split(",")
    $retNumber = @(0,0,0,0,0)
    foreach ($item in $ret) {        
        try {
            [string] $strTemp = ([string]$item)
            [integer] $idx = $strTemp.ToInt16($null) - 1
            if( $idx ){

            }
        }
        catch {
            #Write-Host "Exce��o de divis�o por zero"
        }
    }
}


Clear
$optList = Get-DestProfiles

#Copiar script de incializa��o do ISE para o perfil do usu�rio
<#
[string] $src = "$(scriptRoot)\Microsoft.PowerShellISE_profile.ps1"
[string] $dest = "$env:USERPROFILE\Documents\WindowsPowerShell\Microsoft.PowerShellISE_profile.ps1"
New-Item -ItemTyp File -Force -Path $dest -Confirm | out-null
Copy-Item -Path $src -Destination $dest -Force | out-null
#>