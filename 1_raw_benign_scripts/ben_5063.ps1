function ObterOpcao {

    $_opcao = -1
    while ($_opcao -lt 0 -or $_opcao -gt 6) {
        Write-Host -Object "O que deseja fazer?"
        Write-Host -Object "0 - Sair"
        Write-Host -Object "1 - Executar o escaneamento rapido do Windows Defender"
        Write-Host -Object "2 - Executar o escaneamento completo do Windows Defender"
        Write-Host -Object "3 - Executar o escaneamento offline do Windows Defender"
        Write-Host -Object "4 - Baixar e executar o Kaspersky Virus Removal Tool"
        Write-Host -Object "5 - Baixar e executar o ESET Online Scanner"
        Write-Host -Object "6 - Baixar e executar o Trend Micro HouseCall"
        
        $_opcao = ./Read-Int32.ps1
    }

    return $_opcao
}

$opcao = -1
while ($opcao -ne 0) {
    $opcao = ObterOpcao

    if ($opcao -eq 1) {
        # Atualizando as definicoes de malware
        Update-MpSignature

        # Executando o escaneamento
        Start-MpScan -ScanType QuickScan
    }

    elseif ($opcao -eq 2) {
        # Atualizando as definicoes de malware
        Update-MpSignature

        # Executando o escaneamento
        Start-MpScan -ScanType FullScan
    }

    elseif ($opcao -eq 3) {
        # Atualizando as definicoes de malware
        Update-MpSignature

        # Executando o escaneamento
        Start-MpWDOScan
    }

    elseif ($opcao -eq 4) {
        .\Start-KasperskyVirusRemovalTool.ps1
    }

    elseif ($opcao -eq 5) {
        .\Start-EsetOnlineScanner.ps1
    }

    elseif ($opcao -eq 6) {
        .\Start-TrendMicroHouseCall.ps1
    }
}