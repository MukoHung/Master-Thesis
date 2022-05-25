<#
 # 
 Créer un dossier selon l'arborescence suivante : 

Conversion: 
	|-CAL
	     |-Standard
	     |-Specifique
	|-AL
	|-DELTA
-------------------->-----Cmd------<-----------------

-->Accéder au dossier d'installation de BC ou Nav(>=2018)
===========================================================
-->Dossier d'installation BC 14
#>
cd "C:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\RoleTailored Client"
<#
 # 
 
-->Dossier d'installation NAV
#>
cd "C:\Program Files (x86)\Microsoft Dynamics NAV\110\RoleTailored Client"
<#
 # 
 ===========================================================
-->Locké les objets à exporter sur l'environnement de développement

-->Exporter les objets 
#>
.\finsql.exe Command=ExportToNewSyntax, File="Chemin du dossier\nom du fichier.txt", Database="Nom de la base de données", ServerName=".\Nom de l'instance sql", Filter="Locked By=B2M-IT\trigram"
<#
 # 
 ===========================================================

-------------------->-----PowerShell------<-----------------
===========================================================
-->Si les objets exporté sont que des objets spécifiques, procéder directement à la conversion
#>
.\Txt2Al.exe --source='Dossier source CAL' --target='Dossier destination AL'  --ExtensionStartId=50000
<#
 # 
 
===========================================================
===========================================================
-->Si les objets exporté sont que des objets spécifiques et standards, créer les fichiers de comparaison .DELTA
#>
Compare-NAVApplicationObject -OriginalPath "Chemin dossier CAL\Standard" -ModifiedPath "Chemin dossier CAL\Specifique (modifié)" -DeltaPath "Chemin dossier DELTA" -ExportToNewSyntax
<#
 # En cas d'erreur, veuillez exécuter les commandes en bas du document.
 
->Procéder à la conversion
#>
.\Txt2Al.exe --source='Dossier source DELTA' --target='Dossier destination AL'  --ExtensionStartId=50000
<#
 # 

===========================================================

------------Fin process conversion----------------------------

Autres commandes utiles : 
 
--*--Import module NAV sur Window PowerShell ISE
#>
 
Import-Module 'C:\Program Files\Microsoft Dynamics NAV\110\Service\NavAdminTool.ps1'
<#
 # 
 
--*--BC14 
#>
Import-Module 'C:\Program Files\Microsoft Dynamics 365 Business Central\140\Service\NavAdminTool.ps1'

Import-Module 'C:\Program Files (x86)\Microsoft Dynamics 365 Business Central\140\RoleTailored Client\Microsoft.Dynamics.Nav.Model.Tools.psd1'
<#
 #  
--*--Impossible de lancer des scripts
#>
set-executionpolicy unrestricted



