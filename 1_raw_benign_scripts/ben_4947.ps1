
task IdentifyBuildVariables {

	$BuildNumber = $build_number 
	$RevisionNumber = $build_vcs_number
	$script:AssemblyVersion = "5.0.$BuildNumber.$RevisionNumber"
		
			
	$script:BuildFolder = (pwd).path
	$script:ProjectDirectoryRoot = [io.path]::Combine($BuildFolder, (resolve-path ..).path)
	$script:TemporaryFolder = "$ProjectDirectoryRoot\tmp"
	$script:DeployFolder = "$ProjectDirectoryRoot\Deploy"
	$script:EnvironmentMetaBase = "$ProjectDirectoryRoot\externs\repos\production_metadata"
	
	$script:VcsPath = 'https://xxxxxxxxx.robusthaven.com/repos/xxxxxxxx'
	

	if ($IsInTeamBuild -eq $false) { 
		$script:DevId = [Environment]::GetEnvironmentVariable("$($VariablePrefix)DevId","User")
		$script:DevEnvironment = [Environment]::GetEnvironmentVariable("$($VariablePrefix)DevEnvironment","User")
		$script:DevTask = [Environment]::GetEnvironmentVariable("$($VariablePrefix)DevTask","User")
	}
	else
	{
		$script:DevId = 'TeamCity'
		$script:DevTask = 'integration'
		$script:DevEnvironment = $DevEnvironment
	}
	$script:DevBranch = ([io.path]::GetFileName( (get-item $script:BuildFolder).parent.FullName ) ) 

	$script:NugetDeployFeedFolder = "C:\inetpub\wwwroot\deployfeed-ir\Packages"

	
	$DbPrefix = ''
	$script:Databases = @()
	$script:Databases += New-Database 'Avstx' ($DbPrefix+'Avstx') $true
	$script:Databases += New-Database 'AlohaPOS' ($DbPrefix+'AlohaPOS')
	
		
	$script:StagingEnvironments = @()
	$script:StagingEnvironments += New-StagingEnvironment 'production' ([PackageTypes]::Production)
	
	
	$script:PackageItems = @()
	$script:PackageItems += New-PackageItem	'DashboardWebsite' `
		([ProjectTypes]::Website) `
		"$ProjectDirectoryRoot\Www.DataCenterHost.sln"  `
		"Web.config"  `
		"$DeployFolder\DashboardWebsite"  `
		"$ProjectDirectoryRoot\DataCenter.Www\AVSTX.POS.WebMvc" `
		@() `
		'DashboardWebsite' `
		'DashboardWebsite' `
		'Improving Restaurants' `
		'DashboardWebsite' `
		'http://www.ImprovingRestaurants.com/' `
		'http://www.ImprovingRestaurants.com/' `
		"This is Improving Restaurant's multitenant dashboard." `
		{
			Write-Host 'PreInit'
			$destinationFile = "$ProjectDirectoryRoot\DataCenter.Www\AVSTX.POS.WebRia\ModulesCatalog.xaml";
			cp "$ProjectDirectoryRoot\build\Content\ModulesCatalog.xaml" "$destinationFile"

			(Get-Content $destinationFile) | Foreach-Object {
				$_ -replace '0\.0\.0\.0', $script:AssemblyVersion 
				} | Set-Content $destinationFile
		} `
		{
			Write-Host 'PrePackage'		
				
			$ClientBinDir = "$script:DeployFolder\DashboardWebsite\ClientBin"
			$WebRiaDll = @(
				"$ClientBinDir\AVSTX.POS.WebRia.xap\RobustHaven.Security.Messages.Silverlight.dll",
				"$ClientBinDir\AVSTX.POS.WebRia.xap\RobustHaven.Modules.Helpers.dll",
				"$ClientBinDir\AVSTX.POS.WebRia.xap\RobustHaven.Silverlight.dll",
				"$ClientBinDir\AVSTX.POS.WebRia.xap\RobustHaven.Areas.VersionInfoModule.Silverlight.dll",
				#"$ClientBinDir\AVSTX.POS.WebRia.xap\RobustHaven.Security.Silverlight.dll"
				"$ClientBinDir\AVSTX.POS.WebRia.xap\RobustHaven.Modules.Filtering.Silverlight.dll")

			Write-Host 'Obfuscating AVSTX.POS.WebRia.xap'			
			exec {
				$params = @("-quiet", "-file", "$ClientBinDir\AVSTX.POS.WebRia.xap\AVSTX.POS.WebRia.dll", "-satellite_assemblies", ($WebRiaDll -join '/'), '-targetfile', "$script:TemporaryFolder\AVSTX.POS.WebRia.xap")
				& "$script:ObfuscatorTask" @params
			}

			Write-Host 'Obfuscating AVSTX.Modules.AlertService.Silverlight.xap'
			exec {
				$params = @("-quiet", "-file", "$ClientBinDir\AVSTX.Modules.AlertService.Silverlight.xap\AVSTX.Modules.AlertService.Silverlight.dll", "-targetfile", "$script:TemporaryFolder\AVSTX.Modules.AlertService.Silverlight.xap")
				& "$script:ObfuscatorTask" @params
			}

			Write-Host 'Obfuscating RobustHaven.Modules.SurveyModule.Silverlight.xap'
			exec {
				$params = @("-quiet", "-file", "$ClientBinDir\RobustHaven.Modules.SurveyModule.Silverlight.xap\RobustHaven.Modules.SurveyModule.Silverlight.dll", "-targetfile", "$script:TemporaryFolder\RobustHaven.Modules.SurveyModule.Silverlight.xap")
				& "$script:ObfuscatorTask" @params
			}
			
			Write-Host 'Obfuscating Avstx.Modules.AlarmCodeModule.Silverlight.xap'
			exec {
				$params = @("-quiet", "-file", "$ClientBinDir\Avstx.Modules.AlarmCodeModule.Silverlight.xap\Avstx.Modules.AlarmCodeModule.Silverlight.dll", "-targetfile", "$script:TemporaryFolder\Avstx.Modules.AlarmCodeModule.Silverlight.xap")
				& "$script:ObfuscatorTask" @params
			}
			
			Write-Host 'Obfuscating RobustHaven.Modules.EmailMarketingModule.Silverlight.xap'
			exec {
				$params = @("-quiet", "-file", "$ClientBinDir\RobustHaven.Modules.EmailMarketingModule.Silverlight.xap\RobustHaven.Modules.EmailMarketingModule.Silverlight.dll", "-targetfile", "$script:TemporaryFolder\RobustHaven.Modules.EmailMarketingModule.Silverlight.xap")
				& "$script:ObfuscatorTask" @params
			}
			
			Write-Host 'Obfuscating RobustHaven.Areas.EnterpriseReportingModule.Silverlight.xap'
			exec {
				$params = @("-quiet", "-file", "$ClientBinDir\RobustHaven.Areas.EnterpriseReportingModule.Silverlight.xap\RobustHaven.Areas.EnterpriseReportingModule.Silverlight.dll", "-targetfile", "$script:TemporaryFolder\RobustHaven.Areas.EnterpriseReportingModule.Silverlight.xap")
				& "$script:ObfuscatorTask" @params
			}
			
			Write-Host 'Obfuscating RobustHaven.Areas.CouponModule.Silverlight.xap'
			exec {
				$params = @("-quiet", "-file", "$ClientBinDir\RobustHaven.Areas.CouponModule.Silverlight.xap\RobustHaven.Areas.CouponModule.Silverlight.dll", "-targetfile", "$script:TemporaryFolder\RobustHaven.Areas.CouponModule.Silverlight.xap")
				& "$script:ObfuscatorTask" @params
			}
			
			
			$xaps = @("AVSTX.POS.WebRia.xap",
						"AVSTX.Modules.AlertService.Silverlight.xap",
						"RobustHaven.Modules.SurveyModule.Silverlight.xap",
						"Avstx.Modules.AlarmCodeModule.Silverlight.xap",
						"RobustHaven.Modules.EmailMarketingModule.Silverlight.xap",
						"RobustHaven.Areas.EnterpriseReportingModule.Silverlight.xap",
						"RobustHaven.Areas.CouponModule.Silverlight.xap")

			Write-Host 'Sign Xap(s)'
			foreach($xapFile in  $xaps){
				$waitForFile = "$script:TemporaryFolder\$xapFile"
				WaitForFile($waitForFile)
				exec {
					$params = @("sign", "/v", "/f", "$script:EnvironmentMetaBase\CodeSigningCertificate\Robust-Haven-Inc-RH-Products.p12", '/p', 'fakepassword', '/t', 'http://timestamp.comodoca.com/authenticode', $waitForFile)
					& "$script:SignTask" @params
				}
			}
			
			Write-Host 'Moving xap files'
			foreach($xapFile in  $xaps){
				mv -Force "$script:TemporaryFolder\$xapFile" "$ClientBinDir"
			}
		} `
		{
			Write-Host 'PrePush'
		}
		
	$script:PackageItems += New-PackageItem	'SurveyWebsite' `
		([ProjectTypes]::Website) `
		"$ProjectDirectoryRoot\Www.SurveyHost.sln"  `
		"Web.config"  `
		"$DeployFolder\SurveyWebsite"  `
		"$ProjectDirectoryRoot\Externs\repos\team_surveymodule\HostApp" `
		@() `
		'SurveyWebsite' `
		'SurveyWebsite' `
		'Improving Restaurants' `
		'SurveyWebsite' `
		'http://www.ImprovingRestaurants.com/' `
		'http://www.ImprovingRestaurants.com/' `
		"This is the customer facing survey web application by Improving Restaurants." `
		{
			Write-Host 'PreInit'			
		} `
		{
			Write-Host 'PrePackage'			
		} `
		{
			Write-Host 'PrePush'
		}
		
		
	$script:PackageItems += New-PackageItem	'LanguageWorkbench' `
		([ProjectTypes]::Website) `
		"$ProjectDirectoryRoot\LanguageWorkbench\LanguageWorkbench.sln"  `
		"Web.config"  `
		"$DeployFolder\LanguageWorkbench"  `
		"$ProjectDirectoryRoot\LanguageWorkbench\LanguageWorkbench.Web" `
		@() `
		'LanguageWorkbench' `
		'LanguageWorkbench' `
		'Robust Haven Inc' `
		'LanguageWorkbench' `
		'http://www.robusthaven.com/' `
		'http://www.robusthaven.com/' `
		"This is Robust Haven Inc LanguageWorkbench." `
		{
			Write-Host 'PreInit'			
		} `
		{
			Write-Host 'PrePackage'			
			
			$LanguageWorkbenchClientBinDir = "$script:DeployFolder\LanguageWorkbench\ClientBin"
			
			$LanguageWorkbenchDll = @(
				"$LanguageWorkbenchClientBinDir\LanguageWorkbench.xap\RobustHaven.Windows.Controls.dll",
				"$LanguageWorkbenchClientBinDir\LanguageWorkbench.xap\NPEG.dll")

			Write-Host "Obfuscating LanguageWorkbench.xap"
				exec {
					$params = @("-quiet", "-file", "$LanguageWorkbenchClientBinDir\LanguageWorkbench.xap\LanguageWorkbench.dll", "-satellite_assemblies", ($LanguageWorkbenchDll -join '/'), '-targetfile', "$script:TemporaryFolder\LanguageWorkbench.xap")
					& "$script:ObfuscatorTask" @params
				}				
			
			$waitForFile = "$script:TemporaryFolder\LanguageWorkbench.xap"
			WaitForFile($waitForFile)

			Write-Host 'Sign Xap(s)'
			exec {
				$params = @("sign", "/v", "/f", "$script:EnvironmentMetaBase\CodeSigningCertificate\Robust-Haven-Inc-RH-Products.p12", '/p', 'D6E87765-509E-4CE4-8EA1-9DBE572ACB7D', '/t', 'http://timestamp.comodoca.com/authenticode', $waitForFile)
				& "$script:SignTask" @params
			}
			
			Write-Host 'Moving xap files'
			mv -Force "$script:TemporaryFolder\LanguageWorkbench.xap" $LanguageWorkbenchClientBinDir
		} `
		{
			Write-Host 'PrePush'
		}
		
		
	$script:PackageItems += New-PackageItem	'IRSerialProxy' `
		([ProjectTypes]::DesktopApplication) `
		"$ProjectDirectoryRoot\IRSerialProxy.sln"  `
		"App.config"  `
		"$DeployFolder\IRSerialProxy"  `
		"$ProjectDirectoryRoot\Externs\repos\team_loyalty\IRSerialProxy" `
		@() `
		'IRSerialProxy' `
		'IRSerialProxy' `
		'Improving Restaurants' `
		'IRSerialProxy' `
		'http://www.ImprovingRestaurants.com/' `
		'http://www.ImprovingRestaurants.com/' `
		"IRSerialProxy injects Improving Restaurants loyalty and survey invitations on receipt." `
		{
			Write-Host 'PreInit'			
		} `
		{
			Write-Host 'PrePackage'
			$IRSerialProxyBinDir = "$script:DeployFolder\IRSerialProxy"
			$IRSerialProxyItems = @("$IRSerialProxyBinDir\NPEG.dll", "$IRSerialProxyBinDir\Newtonsoft.Json.dll", "$IRSerialProxyBinDir\zxing.dll", "$IRSerialProxyBinDir\Topshelf.dll")
			
			Write-Host "Obfuscating IRSerialProxy"
			exec {
				$params = @("-quiet", "-file", "$IRSerialProxyBinDir\IRSerialProxy.exe", '-merge', '1', "-satellite_assemblies", ($IRSerialProxyItems -join '/'), '-targetfile', "$script:TemporaryFolder\IRSerialProxy.exe")
				& "$script:ObfuscatorTask" @params
			}
			
			$waitForFile = "$script:TemporaryFolder\IRSerialProxy.exe"
			WaitForFile($waitForFile)
			
			Write-Host 'Moving exe files'
			mv -Force "$script:TemporaryFolder\IRSerialProxy.exe" $IRSerialProxyBinDir

			foreach($item in $IRSerialProxyItems)
			{
				rm $item
			}
		} `
		{
			Write-Host 'PrePush'
		}
		
		
	$script:PackageItems += New-PackageItem	'RobustHaven.Services.SurveyModule' `
		([ProjectTypes]::WindowService) `
		"$ProjectDirectoryRoot\WindowServices.sln"  `
		"App.config"  `
		"$DeployFolder\RobustHaven.Services.SurveyModule"  `
		"$ProjectDirectoryRoot\WindowServices\RobustHaven.Services.SurveyModule" `
		@() `
		'RobustHaven.Services.SurveyModule' `
		'RobustHaven.Services.SurveyModule' `
		'Improving Restaurants' `
		'RobustHaven.Services.SurveyModule' `
		'http://www.ImprovingRestaurants.com/' `
		'http://www.ImprovingRestaurants.com/' `
		"Service used to manage coupons and sagas needed by the SurveyModule." `
		{
			Write-Host 'PreInit'			
		} `
		{
			Write-Host 'PrePackage'
		} `
		{
			Write-Host 'PrePush'
		}
		
		
	$script:PackageItems += New-PackageItem	'RobustHaven.Services.AlohaDbfImport' `
		([ProjectTypes]::WindowService) `
		"$ProjectDirectoryRoot\WindowServices.sln"  `
		"App.config"  `
		"$DeployFolder\RobustHaven.Services.AlohaDbfImport"  `
		"$ProjectDirectoryRoot\WindowServices\RobustHaven.Services.AlohaDbfImport" `
		@() `
		'RobustHaven.Services.AlohaDbfImport' `
		'RobustHaven.Services.AlohaDbfImport' `
		'Improving Restaurants' `
		'RobustHaven.Services.AlohaDbfImport' `
		'http://www.ImprovingRestaurants.com/' `
		'http://www.ImprovingRestaurants.com/' `
		"Service used to measure social impact for our tenants multiple campaigns." `
		{
			Write-Host 'PreInit'
		} `
		{
			Write-Host 'PrePackage'
			if ($IsInTeamBuild -eq $true) { 
				$tools = @(
					"$ProjectDirectoryRoot\build\tools\7-Zip\7z.dll",
					"$ProjectDirectoryRoot\build\tools\7-Zip\7z.exe",
					"$ProjectDirectoryRoot\Externs\repos\production_metadata\Pgp\ImprovingRestaurants.secret.pgp")
					
				new-item "$DeployFolder\RobustHaven.Services.AlohaDbfImport\Tools" -itemType directory
			
				foreach($tool in $tools)
				{
					$toolName = [system.io.path]::GetFileName($tool);
					cp $tool "$DeployFolder\RobustHaven.Services.AlohaDbfImport\Tools\$toolName"
				}
			}
		} `
		{
			Write-Host 'PrePush'
		}
		
		
	$script:PackageItems += New-PackageItem	'RobustHaven.Services.EmailMarketingModule' `
		([ProjectTypes]::WindowService) `
		"$ProjectDirectoryRoot\WindowServices.sln"  `
		"App.config"  `
		"$DeployFolder\RobustHaven.Services.EmailMarketingModule"  `
		"$ProjectDirectoryRoot\WindowServices\EmailMarketingModule" `
		@() `
		'RobustHaven.Services.EmailMarketingModule' `
		'RobustHaven.Services.EmailMarketingModule' `
		'Improving Restaurants' `
		'RobustHaven.Services.EmailMarketingModule' `
		'http://www.ImprovingRestaurants.com/' `
		'http://www.ImprovingRestaurants.com/' `
		"Service used to process queued mail one at a time, insert a mailstatus id to track mail, and report failed smtp delivery." `
		{
			Write-Host 'PreInit'			
		} `
		{
			Write-Host 'PrePackage'
		} `
		{
			Write-Host 'PrePush'
		}
		
		
	$script:PackageItems += New-PackageItem	'RobustHaven.Services.SocialImpact' `
		([ProjectTypes]::WindowService) `
		"$ProjectDirectoryRoot\WindowServices.sln"  `
		"App.config"  `
		"$DeployFolder\RobustHaven.Services.SocialImpact"  `
		"$ProjectDirectoryRoot\WindowServices\RobustHaven.Services.SocialImpact" `
		@() `
		'RobustHaven.Services.SocialImpact' `
		'RobustHaven.Services.SocialImpact' `
		'Improving Restaurants' `
		'RobustHaven.Services.SocialImpact' `
		'http://www.ImprovingRestaurants.com/' `
		'http://www.ImprovingRestaurants.com/' `
		"Service used to measure social impact for our tenants multiple campaigns." `
		{
			Write-Host 'PreInit'			
		} `
		{
			Write-Host 'PrePackage'
		} `
		{
			Write-Host 'PrePush'
		}
		
		
	$script:PackageItems += New-PackageItem	'RobustHaven.Services.ServiceMonitor' `
		([ProjectTypes]::WindowService) `
		"$ProjectDirectoryRoot\WindowServices.sln"  `
		"App.config"  `
		"$DeployFolder\RobustHaven.Services.ServiceMonitor"  `
		"$ProjectDirectoryRoot\WindowServices\RobustHaven.Services.ServiceMonitor" `
		@() `
		'RobustHaven.Services.ServiceMonitor' `
		'RobustHaven.Services.ServiceMonitor' `
		'Improving Restaurants' `
		'RobustHaven.Services.ServiceMonitor' `
		'http://www.ImprovingRestaurants.com/' `
		'http://www.ImprovingRestaurants.com/' `
		"Ensures services are running, alerts when queues are overflowing, auto updates applications." `
		{
			Write-Host 'PreInit'			
		} `
		{
			Write-Host 'PrePackage'
		} `
		{
			Write-Host 'PrePush'
		}
		
		
	$script:PackageItems += New-PackageItem	'IRDataCaptureServer' `
		([ProjectTypes]::WindowService) `
		"$ProjectDirectoryRoot\WindowServices.sln"  `
		"App.config"  `
		"$DeployFolder\IRDataCaptureServer"  `
		"$ProjectDirectoryRoot\WindowServices\IRDataCaptureServer" `
		@() `
		'IRDataCaptureServer' `
		'IRDataCaptureServer' `
		'Improving Restaurants' `
		'IRDataCaptureServer' `
		'http://www.ImprovingRestaurants.com/' `
		'http://www.ImprovingRestaurants.com/' `
		"Listens for alert messages via http and saves them into database." `
		{
			Write-Host 'PreInit'			
		} `
		{
			Write-Host 'PrePackage'
		} `
		{
			Write-Host 'PrePush'
		}


		
		
	$script:PackageItems += New-PackageItem	'DbChangeManagement' `
		([ProjectTypes]::XCopy) `
		"$ProjectDirectoryRoot\build\Octopus\Step.DatabaseChangeManagement"  `
		"Web.config"  `
		"$DeployFolder\DbChangeManagement"  `
		"$ProjectDirectoryRoot\build\Octopus\Step.DatabaseChangeManagement" `
		@() `
		'DbChangeManagement' `
		'' `
		'' `
		'' `
		'' `
		'' `
		'' `
		{
			Write-Host 'PreInit'			
		} `
		{ 
			Write-Host 'PrePackage'		
			cp ($script:BuildFolder + '\tools\RobustHaven.Tasks\RobustHaven.Tasks.dll')  "$DeployFolder\DbChangeManagement"
			cp ($script:BuildFolder + '\tools\RobustHaven.Tasks\RobustHaven.Tasks.Targets')  "$DeployFolder\DbChangeManagement"
			cp ($script:ProjectDirectoryRoot + '\Databases')  "$DeployFolder\DbChangeManagement\Databases" -rec -filter *.sql 
			cp ($script:ProjectDirectoryRoot + '\Databases\Avstx\RobustHaven.SqlClr.dll')  "$DeployFolder\DbChangeManagement\Databases\Avstx"
		} `
		{
			Write-Host 'PrePush'			
		} `

	$script:PackageItems += New-PackageItem	'App_Offline' `
		([ProjectTypes]::XCopy) `
		"$ProjectDirectoryRoot\build\Octopus\Step.App_Offline"  `
		"Web.config"  `
		"$DeployFolder\App_Offline"  `
		"$ProjectDirectoryRoot\build\Octopus\Step.App_Offline" `
		@() `
		'App_Offline' `
		'' `
		'' `
		'' `
		'' `
		'' `
		'' `
		{
			Write-Host 'PreInit'			
		} `
		{
			Write-Host 'PrePackage'	
		} `
		{
			Write-Host 'PrePush'	
		}

	$script:PackageItems += New-PackageItem	'PurgeActivityForDeployment' `
		([ProjectTypes]::XCopy) `
		"$ProjectDirectoryRoot\build\Octopus\Step.PurgeActivityForDeployment"  `
		"Web.config"  `
		"$DeployFolder\PurgeActivityForDeployment"  `
		"$ProjectDirectoryRoot\build\Octopus\Step.PurgeActivityForDeployment" `
		@() `
		'PurgeActivityForDeployment' `
		'' `
		'' `
		'' `
		'' `
		'' `
		'' `
		{
			Write-Host 'PreInit'			
		} `
		{
			Write-Host 'PrePackage'	
		} `
		{
			Write-Host 'PrePush'	
		}
		
	$script:PackageItems += New-PackageItem	'InfrastructureChangeManagement' `
		([ProjectTypes]::XCopy) `
		"$ProjectDirectoryRoot\build\Octopus\Step.InfrastructureChangeManagement"  `
		"Web.config"  `
		"$DeployFolder\InfrastructureChangeManagement"  `
		"$ProjectDirectoryRoot\build\Octopus\Step.InfrastructureChangeManagement" `
		@() `
		'InfrastructureChangeManagement' `
		'' `
		'' `
		'' `
		'' `
		'' `
		'' `
		{
			Write-Host 'PreInit'			
		} `
		{ 
			cp ($script:BuildFolder + '\tools\RobustHaven.Tasks\RobustHaven.Tasks.dll')  "$DeployFolder\InfrastructureChangeManagement"
			cp ($script:BuildFolder + '\tools\RobustHaven.Tasks\RobustHaven.Tasks.Targets')  "$DeployFolder\InfrastructureChangeManagement"
			cp ($script:ProjectDirectoryRoot + '\InfraScripts')  "$DeployFolder\InfrastructureChangeManagement\InfraScripts" -rec -filter *.ps1 
		} `
		{
			Write-Host 'PrePush'	
		}

		
		
	
	
	Generate-Assembly-Info `
		-file ("{0}\GlobalAssemblyInfo.cs" -f $ProjectDirectoryRoot) `
		-company $CompanyName `
		-product ("{0} {1}" -f $DevProduct, $script:AssemblyVersion) `
		-version $script:AssemblyVersion `
		-clsCompliant "false" `
		-copyright ("{0} 2013" -f $CompanyName)
		
		
	
	$script:NugetTask = "$script:BuildFolder\tools\.nuget\NuGet.exe"
	$script:FlexibleConfigTask = $script:BuildFolder + '\tools\RobustHaven.Tasks\_FlexibleConfigTask.proj'
	$script:DatabaseChangeManagementTask = $script:BuildFolder + '\tools\RobustHaven.Tasks\_DatabaseChangeManagementTask.proj'
	$script:PowershellTask = $script:BuildFolder + '\tools\RobustHaven.Tasks\_PowershellTask.proj'
	$script:XDTTask = $script:BuildFolder + '\tools\RobustHaven.Tasks\_XDT.proj'
	$script:ObfuscatorTask ='C:\Program Files (x86)\Eziriz\.NET Reactor\dotNET_Reactor.exe'
	$script:SignTask = 'C:\Program Files (x86)\Microsoft SDKs\Windows\v7.0A\Bin\signtool.exe'
	
	
	
	
	
	$tmp = "no"
	if ($IsInTeamBuild -eq $true) { 
		$tmp = "yes" 
	}
	$response = "Your response: DevProduct:{0}, DevBranch:{1}, DevEnvironment:{2}, DevTask:{3}, DevId:{4}, IsInTeamBuild:{5}" -f $DevProduct, $script:DevBranch, $script:DevEnvironment, $script:DevTask, $script:DevId, $tmp
	Write-Host $response
}