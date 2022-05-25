����cmd
1.ִ�����ýű���������
Set-ExecutionPolicy remotesigned
2.ִ�е����ű����
powershell D:\DBAScripts\Script-Db.ps1 198.168.1.123 48330 sa 86668sT test,test2 D:\DBAScripts\DBSchemas.sql

powershell D:\DBAScripts\Script-Db-Table.ps1 192.168.1.16 48330 sa 86668sT audit001,linworld001 D:\DBAScripts\test-table.sql
powershell D:\DBAScripts\Script-Db-Table.ps1 192.168.1.21 48330 sa 86668sT lin2world D:\DBAScripts\test-table.sql

powershell D:\DBAScripts\Script-Db-Fun.ps1 192.168.1.11 48330 sa 86668sT FCT31MudV1,FCT31MudV1Log D:\DBAScripts\test-fun.sql


powershell D:\DBAScripts\Script-Db-Db.ps1 198.168.1.123 48330 test,test2 D:\DBAScripts\test-db.sql

powershell D:\DBAScripts\Script-Db-Table.ps1 10.158.146.43 48330 sa 86668sT test,test2 D:\DBAScripts\test-table.sql
powershell D:\DBAScripts\Script-Db-Proc.ps1 198.168.1.123 48330 sa 86668sT test,test2 D:\DBAScripts\test-proc.sql
powershell D:\DBAScripts\Script-Db-View.ps1 198.168.1.123 48330 sa 86668sT  test,test2 D:\DBAScripts\test-view.sql

powershell D:\DBAScripts\Script-Db-Fun.ps1 198.168.1.123 48330 sa 86668sT test,test2 D:\DBAScripts\test-fun.sql

powershell D:\DBAScripts\Script-Db-Schema.ps1 198.168.1.123 48330 sa 86668sT test,test2 D:\DBAScripts\test-schema.sql

powershell D:\DBAScripts\Script-Db-User.ps1 198.168.1.123 48330 sa 86668sT test,test2 D:\DBAScripts\test-user.sql
