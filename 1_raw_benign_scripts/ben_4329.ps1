#Script para execucao de testes unitarios 
#LIB - Caso Teste Negativo Script sem caminho codigo fonte
C:\andre\devrepogit\github\jenkinsci\ssetool\tools\pshell\ScriptZipJKS.ps1 
#LIB - Caso Teste Negativo Script sem nome da applicacao
C:\andre\devrepogit\github\jenkinsci\ssetool\tools\pshell\ScriptZipJKS.ps1 'c:\pst\origem\bin'  
#LIB - Caso Teste Negativo Script sem tipo do app 
C:\andre\devrepogit\github\jenkinsci\ssetool\tools\pshell\ScriptZipJKS.ps1 'c:\pst\origem\bin' 'sistema'
#LIB - Caso Teste Negativo Script sem arquivo informado 
C:\andre\devrepogit\github\jenkinsci\ssetool\tools\pshell\ScriptZipJKS.ps1 'c:\pst\origem\bin' 'sistema' 'lib'


#LIB - Casos de Testes ZIP-AppLib
clear
remove-item c:\pst -Force -Recurse
new-item 'c:\pst\origem' -ItemType directory -Force
new-item 'c:\pst\origem\bin' -ItemType directory -Force
new-item 'c:\pst\origem\subpasta' -ItemType directory -Force
new-item 'c:\pst\destino' -ItemType directory -Force
new-item 'c:\pst\origem\bin\lib1.txt' -Value 'lib1'  -ItemType file -Force
new-item 'c:\pst\origem\bin\modulo.txt' -Value 'modulo'  -ItemType file -Force
new-item 'c:\pst\origem\bin\lib3.txt' -Value 'lib3'  -ItemType file -Force
new-item 'c:\pst\origem\bin\lib4.txt' -Value 'lib4'  -ItemType file -Force

#SUCESSO 
#LIB - Caso 1 Teste Sucesso ZIP-AppLib arquivos selecionados um
C:\andre\devrepogit\github\jenkinsci\ssetool\tools\pshell\ScriptZipJKS.ps1 "c:\pst\origem\bin" "sistema" "lib" "modulo.txt"
#LIB - Caso 2 Teste Sucesso ZIP-AppLib arquivos selecionados + de um arquivo
C:\andre\devrepogit\github\jenkinsci\ssetool\tools\pshell\ScriptZipJKS.ps1 "c:\pst\origem\bin" "sistema" "lib" @('modulo.txt','lib1.txt')
#LIB - Caso 2 Teste Sucesso ZIP-AppLib todos os arquivos 
C:\andre\devrepogit\github\jenkinsci\ssetool\tools\pshell\ScriptZipJKS.ps1 "c:\pst\origem\bin" "sistema" "lib" "*.*"
#ERRO
C:\andre\devrepogit\github\jenkinsci\ssetool\tools\pshell\ScriptZipJKS.ps1 "c:\apst\origem\bin" "sistema" "lib" "modulo.txt" 

#Casos de Testes ZIP-AppWeb
clear
remove-item c:\pst -Force -Recurse
new-item 'c:\pst\destino' -ItemType directory -Force
new-item 'c:\pst\destino\apptemp' -ItemType directory -Force
new-item 'c:\pst\destino\apptemp\bin' -ItemType directory -Force
new-item 'c:\pst\destino\apptemp\subpasta' -ItemType directory -Force
new-item 'c:\pst\destino\apptemp\subpasta2' -ItemType directory -Force
new-item 'c:\pst\destino\apptemp\subpasta2\subpasta3' -ItemType directory -Force
new-item 'c:\pst\destino\apptemp\bin\lib1.txt' -Value 'lib1'  -ItemType file -Force
new-item 'c:\pst\destino\apptemp\bin\modulo.txt' -Value 'modulo'  -ItemType file -Force
new-item 'c:\pst\destino\apptemp\bin\lib3.txt' -Value 'lib3'  -ItemType file -Force
new-item 'c:\pst\destino\apptemp\bin\lib4.txt' -Value 'lib4'  -ItemType file -Force
new-item 'c:\pst\destino\apptemp\web1.aspx' -Value 'webpage1'  -ItemType file -Force
new-item 'c:\pst\destino\apptemp\web2.aspx' -Value 'webpage2'  -ItemType file -Force
new-item 'c:\pst\destino\apptemp\web.config' -Value 'webconfig'  -ItemType file -Force
new-item 'c:\pst\destino\apptemp\subpasta\web3.aspx' -Value 'webpage3'  -ItemType file -Force

#LIB - Caso 1 Teste Sucesso  arquivos selecionados um
C:\andre\devrepogit\github\jenkinsci\ssetool\tools\pshell\ScriptZipJKS.ps1 "c:\pst\destino\apptemp" "sistema" "appweb" "modulo.txt"
#LIB - Caso 2 Teste Sucesso arquivos selecionados + de um arquivo
C:\andre\devrepogit\github\jenkinsci\ssetool\tools\pshell\ScriptZipJKS.ps1 "c:\pst\destino\apptemp" "sistema" "appweb" @('modulo.txt','lib1.txt')
#LIB - Caso 2 Teste Sucesso  todos os arquivos 
C:\andre\devrepogit\github\jenkinsci\ssetool\tools\pshell\ScriptZipJKS.ps1 "c:\pst\destino\apptemp" "sistema" "appweb" "*.*"
#ERRO
C:\andre\devrepogit\github\jenkinsci\ssetool\tools\pshell\ScriptZipJKS.ps1 "c:\apst\origem\bin" "sistema" "appweb" "modulo.txt" 


#Casos de Testes ZIP-AppModuloNet
clear
remove-item c:\pst -Force -Recurse
new-item 'c:\pst\destino' -ItemType directory -Force
new-item 'c:\pst\destino\portalnet' -ItemType directory -Force
new-item 'c:\pst\destino\portalnet\paginas\Sistema.Pages' -ItemType directory -Force
new-item 'c:\pst\destino\portalnet\paginas\Sistema.Pages\bin' -ItemType directory -Force
new-item 'c:\pst\destino\portalnet\paginas\Sistema.Pages\subpasta' -ItemType directory -Force
new-item 'c:\pst\destino\portalnet\paginas\Sistema.Pages\subpasta2' -ItemType directory -Force
new-item 'c:\pst\destino\portalnet\paginas\Sistema.Pages\subpasta2\subpasta3' -ItemType directory -Force
new-item 'c:\pst\destino\portalnet\paginas\Sistema.Pages\bin\lib1.txt' -Value 'lib1'  -ItemType file -Force
new-item 'c:\pst\destino\portalnet\paginas\Sistema.Pages\bin\modulo.txt' -Value 'modulo'  -ItemType file -Force
new-item 'c:\pst\destino\portalnet\paginas\Sistema.Pages\bin\lib3.txt' -Value 'lib3'  -ItemType file -Force
new-item 'c:\pst\destino\portalnet\paginas\Sistema.Pages\bin\lib4.txt' -Value 'lib4'  -ItemType file -Force
new-item 'c:\pst\destino\portalnet\paginas\Sistema.Pages\web1.aspx' -Value 'webpage1'  -ItemType file -Force
new-item 'c:\pst\destino\portalnet\paginas\Sistema.Pages\web2.aspx' -Value 'webpage2'  -ItemType file -Force
new-item 'c:\pst\destino\portalnet\paginas\Sistema.Pages\web.config' -Value 'webconfig'  -ItemType file -Force
new-item 'c:\pst\destino\portalnet\paginas\Sistema.Pages\subpasta\web3.aspx' -Value 'webpage3'  -ItemType file -Force

#LIB - Caso 1 Teste Sucesso  arquivos selecionados um
C:\andre\devrepogit\github\jenkinsci\ssetool\tools\pshell\ScriptZipJKS.ps1 "c:\pst\destino\portalnet\paginas\Sistema.Pages" "sistema" "appnet" "modulo.txt"
#LIB - Caso 2 Teste Sucesso arquivos selecionados + de um arquivo
C:\andre\devrepogit\github\jenkinsci\ssetool\tools\pshell\ScriptZipJKS.ps1 "c:\pst\destino\portalnet\paginas\Sistema.Pages" "sistema" "appnet" @('modulo.txt','lib1.txt')
#LIB - Caso 2 Teste Sucesso  todos os arquivos 
C:\andre\devrepogit\github\jenkinsci\ssetool\tools\pshell\ScriptZipJKS.ps1 "c:\pst\destino\portalnet\paginas\Sistema.Pages" "sistema" "appnet" "*.*"
#ERRO
C:\andre\devrepogit\github\jenkinsci\ssetool\tools\pshell\ScriptZipJKS.ps1 "c:\pst\destino\portalnet\paginas\Sistema.Pages" "sistema" "appnet" "modulo.txt" 

