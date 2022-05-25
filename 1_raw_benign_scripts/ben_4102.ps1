<#
  .SYNOPSIS
  Test la disponibilité des adresses. Necessite PowerShell v5 minimum pour fonctionner, pour tester la version de votre Powershell tapez $PSVersionTable.PSVersion

  .DESCRIPTION
  Fonctionne seulement sur une plage en /24 (255.255.255.0). Ce script vous indiquera les IP disponibles.

  .PARAMETER adresse
  Indiquez les trois premiers octets de la plage à tester. N'indiquez pas le '.' final, reportez vous à la section exemple.

  .PARAMETER debut
  Indiquer l'IP de début de plage.

  .PARAMETER fin
  Undiquer la dernière adresse de la plage IP que vous voulez tester.

  .EXAMPLE
  PS> .\Test-PlageIP.ps1  -adresse 192.168.1 -debut 1 -fin 20
  Permet de tester toutes les IP entre 192.168.1.1 et 192.168.1.20

  .NOTES
  Auteur : VOIRIN Vincent, v2.0
  v.1 = original, test simple de requête ICMP
  v.2 = ajout d'un test de correspance dans le cache ARP en cas de pc ne répondant pas aux requêtes ICMP (firewall block echo request).
#>
#Requires -Version 5.0

param(
    [Parameter(Mandatory)][string]$adresse,
    [Parameter(Mandatory)][int32]$debut,
    [Parameter(Mandatory)][int32]$fin)

function Test-ExistenceCommand
{
    $exist = Get-Command -Name Get-NetNeighbor -ErrorAction SilentlyContinue
    if ( $null -eq $exist )
    {
        Test-PlageIP
    }
    else
    {
        Test-PlageARP
    }
}
function Test-PlageIP
{
    [array]$range = $debut..$fin
    foreach ($ip in $range)
    { 
        $result = Test-Connection -Count 1 -ComputerName "$adresse.$ip" -Quiet
        if ( $result -eq $false )
        {
            Write-Output "$adresse.$ip est libre"
        }
    }
}
function Test-PlageARP
{
    [array]$range = $debut..$fin
    [PsObject]$arp = Get-NetNeighbor -AddressFamily IPv4 -State Reachable, Stale
    foreach ($ip in $range)
    {
        $result = Test-Connection -ComputerName "$adresse.$ip" -Count 1 -Quiet
        if ( $result -eq $false )
        {
            if ( $result -notin $arp.IPAddress )
                {
                    Write-Output "$adresse.$ip est libre"
                }
        }
    }
}

Test-ExistenceCommand