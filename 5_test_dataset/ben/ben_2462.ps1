#Adapted from  https://gist.github.com/tugberkugurlu/11212976
#Used in ARM template deployment

configuration MongoDB {
    #param (
    #    [string[]]$ComputerName = $env:ComputerName
    #)

	Import-DSCResource -ModuleName xDisk
	Import-DSCResource -ModuleName cDisk

    node LocalHost {
	    xWaitforDisk Disk2
        {
             DiskNumber = 2
             RetryIntervalSec = 20
             RetryCount = 30
        }

        cDiskNoRestart ADDataDisk
        {
            DiskNumber = 2
            DriveLetter = "F"
        }

        File SetupFolder {
            Type = 'Directory'
            DestinationPath = "C:\setup"
            Ensure = 'Present'
        }

        Script DownloadMongoBinaries
        {
            SetScript = {
                Invoke-WebRequest 'http://fastdl.mongodb.org/win32/mongodb-win32-x86_64-2008plus-ssl-3.2.8-signed.msi' -OutFile "C:\setup\mongodb-win32-x86_64-2008plus-ssl-3.2.8-signed.msi"
            }
            TestScript = { Test-Path "C:\setup\mongodb-win32-x86_64-2008plus-ssl-3.2.8-signed.msi" }
            GetScript = { @{MongoBinariesDownloaded = $(Test-Path "C:\setup\mongodb-win32-x86_64-2008plus-ssl-3.2.8-signed.msi") } }
            DependsOn = '[File]SetupFolder'
        }

		Script SetupMongo {
			SetScript = {
				Start-Process msiexec.exe -ArgumentList "/qn /i `"c:\setup\mongodb-win32-x86_64-2008plus-ssl-3.2.8-signed.msi`" INSTALLLOCATION=`"C:\mongoDB`" ADDLOCAL=`"ALL`"" -Wait
			}
			TestScript = {
				Test-Path "C:\mongoDB\bin"
			}
			GetScript = { @{MongoBinariesDownloaded = $(Test-Path "C:\setup\mongodb-win32-x86_64-2008plus-ssl-3.2.8-signed.msi") } }
			DependsOn = '[Script]DownloadMongoBinaries'
		}

        File MongoDBFolder {
            Type = 'Directory'
            Recurse = $true
            DestinationPath = "C:\mongoDB"
            SourcePath = "c:\setup"
            Ensure = 'Present'
            DependsOn = '[Script]SetupMongo'
        }

        File MongoDataFolder {
            Type = 'Directory'
            DestinationPath = "F:\mongo\data"
            Ensure = 'Present'
            DependsOn = '[File]MongoDBFolder'
        }

        File MongoLogsFolder {
            Type = 'Directory'
            DestinationPath = "F:\mongo\logs"
            Ensure = 'Present'
            DependsOn = '[File]MongoDBFolder'
        }

        File MongoConfigFolder {
            Type = 'Directory'
            DestinationPath = "C:\mongo\config"
            Ensure = 'Present'
            DependsOn = '[File]MongoDBFolder'
        }

        Script MongoConfigurationFile
        {
            SetScript = { 
                $utf8WithoutBom = New-Object System.Text.UTF8Encoding($false);
                $sw = New-Object System.IO.StreamWriter('C:\mongo\config\mongod.cfg', $false, $utf8WithoutBom)
                $sw.WriteLine('logpath=F:\mongo\logs\mongo.log')
                $sw.WriteLine('dbpath=F:\mongo\data')
                $sw.WriteLine('replSet=rs')
                $sw.WriteLine('oplogSize=700')
                $sw.WriteLine('port=27017')
                $sw.WriteLine('#auth=true')
                $sw.WriteLine('#keyFile=C:\mongo\config\keyfile.txt')
                $sw.Close()
            }
            TestScript = { Test-Path 'C:\mongo\config\mongod.cfg' }
            GetScript = { @{MongoConfigured = (Test-Path 'C:\mongo\config\mongod.cfg')} }          
            DependsOn = '[File]MongoConfigFolder'
        }

        Script MongoKeyFile
        {
            SetScript = { 
                $utf8WithoutBom = New-Object System.Text.UTF8Encoding($false);
                $sw = New-Object System.IO.StreamWriter('C:\mongo\config\keyfile.txt', $false, $utf8WithoutBom)
                $sw.Write('hEGYEYqqgUBDC0Qy8P0xC4lUmOFpmIUlVMN5c1BZJ6vAM3XQS4v73YPNbrSWJ8IY')
                $sw.Close()
            }
            TestScript = { Test-Path 'C:\mongo\config\keyfile.txt' }
            GetScript = { @{MongoConfigured = (Test-Path 'C:\mongo\config\keyfile.txt')} }          
            DependsOn = '[File]MongoConfigFolder'
        }

        Script InstallMongoService
        {
            SetScript = { 
               C:\mongoDB\bin\mongod.exe --config `"C:\mongo\config\mongod.cfg`" --install
				Set-Service mongoDB -StartupType Automatic
				
            }
            TestScript = { (Get-Service | Where-Object { $_.Name -eq 'MongoDB' }).Count -gt 0 }
            GetScript = { @{MongoServiceInstalled = ((Get-Service-NAm | Where-Object { $_.Name -eq 'MongoDB' }).Count -gt 0) } }
            DependsOn = '[Script]MongoConfigurationFile','[script]MongoKeyFile','[Script]SetupMongo'
        }


		Script StartMongoService {
            SetScript = { 
				Start-Service mongoDB
				
            }
            TestScript = { (Get-Service -Name MongoDB | Where-Object { $_.status -eq 'Running' }).Count -gt 0 }
            GetScript = { @{MongoServiceInstalled = ((Get-Service -Name MongoDB | Where-Object { $_.status -eq 'Running' }).Count -gt 0) } }
            DependsOn = '[Script]InstallMongoService','[File]MongoLogsFolder','[File]MongoDataFolder'

		}

        Script ConfigureFirewall
        {
            SetScript = { New-NetFirewallRule -Name Allow_MongoDB -DisplayName 'Allow MongoDB' -Description 'Allow inbound MongoDB connections' -Direction Inbound -Program 'C:\mongoDB\bin\mongod.exe' -Action Allow }
            TestScript = { (Get-NetFirewallRule | Where-Object { $_.Name -eq 'Allow_MongoDB' }) -ne $null }
            GetScript = { @{FirewallConfiguredForMongo = ((Get-NetFirewallRule | Where-Object { $_.Name -eq 'Allow_MongoDB' }).Count -gt 0) } }
        }
    }
}
