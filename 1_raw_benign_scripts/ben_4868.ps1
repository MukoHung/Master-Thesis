## wget https://download.microsoft.com/download/B/D/8/BD821B1F-05F2-4A7E-AA03-DF6C4F687B07/dgreadiness_v3.6.zip
## unzip dgreadiness_v3.6.zip
cd dgreadiness_v3.6

Set-ExecutionPolicy Unrestricted -force
.\DG_Readiness_Tool_v3.6.ps1 -Capable
.\DG_Readiness_Tool_v3.6.ps1 -Enable .\DefaultWindows_Audit_sipolicy.p7b
.\DG_Readiness_Tool_v3.6.ps1 -Disable dg
