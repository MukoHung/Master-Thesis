# 00.CreateReportKCO.ps1
#
# SYDI-Server is a tool for documenting Windows computers To run the script: cscript.exe sydi-server.vbs (-h for help)
# http://sydiproject.com/download/
#
#
# Documentation will be stored as ..REPORTS\%Computername%.XML
# KCO
#   \\AMSTERDAM\DFS\Library\SYDI\REPORTS\%Computername%.xml
# FVL
# 	\\nfcpca01.fvlprod.fvl\Secure\ITM\IT Operations\Windows\00 Afdeling\09 Decommissioning\Uitgevoerd\REPORTS\%Computername%.XML
#
# Location of 00.CreateReportFVL.ps1 script
# 	\\nfcpca01.fvlprod.fvl\Secure\ITM\IT Operations\Windows\00 Afdeling\09 Decommissioning\Scripts\00.CreateReportFVL.ps1
# 	\\nfcpca01.fvlprod.fvl\Secure\ITM\IT Operations\Windows\00 Afdeling\09 Decommissioning\Scripts\00.CreateReportKCO.ps1
# Software locations:
#	KCO
# 	\\AMSTERDAM\DFS\Library\SYDI\sydi-server.vbs
#	FVL
# 	\\nfcpca01.fvlprod.fvl\SoftwareRepository\Software\SYDI\sydi-server.vbs
# 
# Run the Script on the local machine as ADMINISTRATOR!
# 
PAUSE

C:
REM KCO
C:\windows\System32\cscript.exe \\AMSTERDAM\DFS\Library\SYDI\sydi-server.vbs -ex -o"\\AMSTERDAM\DFS\Library\SYDI\REPORTS\%Computername%.xml" -t%ComputerName%
REM FVL
REM C:\windows\System32\cscript.exe \\nfcpca01.fvlprod.fvl\SoftwareRepository\Software\SYDI\sydi-server.vbs -ex -o"\\nfcpca01.fvlprod.fvl\Secure\ITM\IT Operations\Windows\00 Afdeling\09 Decommissioning\Uitgevoerd\REPORTS\%Computername%.XML" -t%ComputerName%

