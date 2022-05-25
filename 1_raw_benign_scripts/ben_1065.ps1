#http://tavalik.ru/zapusk-neskolkix-serverov-1spredpriyatiya-raznyx-versij/
#http://tavalik.ru/agent-servera-1spredpriyatiya-8-ego-parametry-zapuska/

cd 'C:\Program Files\1cv8\8.3.10.2466\bin'
.\ragent.exe -rmsrvc
.\ragent.exe -instsrvc -port 1540 -regport 1541 -range 1560:1591 -usr .\USR1CV8 -pwd UsrPass8 -d "C:\Program Files\1cv8\srvinfo"
#Установка сервиса данным способ убивает другие имеющиеся службы сервера 1С, при необходимости создания более одной службы пользуемся утилитой sc

#С помощью sc:
sc create "1c-server-1640" binPath= "\"C:\Program Files (x86)\1cv8\8.3.13.1513\bin\ragent.exe\" -srvc -agent -port 1640 -regport 1641 -range 1660:1691 -d \"C:\Program Files (x86)\1cv8\srvinfo2"" start= auto displayname= "Агент сервера 1С:Предприятия 8.3 (1640)" obj= ".\USR1CV8" password= "pwd
