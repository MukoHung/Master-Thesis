$win10_builtin = @('AppVClient', 'ClickToRunSvc', 'COMSysApp', 'diagnosticshub.standardcollector.service',
           'msiserver', 'ose', 'perceptionsimulation', 'SecurityHealthService', 'Sense',
           'SensorDataService', 'SgrmBroker', 'Spooler', 'ssh-agent', 'TieringEngineService',
           'TrustedInstaller', 'UevAgentService', 'vds', 'VSS', 'wbengine', 'WinDefend', 'wmiApSrv',
           'WSearch', 'XboxNetApiSvc', 'XboxGipSvc', 'XblGameSave', 'XblAuthManager', 'WwanSvc', 'wuauserv',
           'WwanSvc', 'wuauserv', 'WpnService', 'WPDBusEnum', 'WpcMonSvc', 'WManSvc', 'wlidsvc', 'WlanSvc',
           'wisvc', 'Winmgmt', 'WiaRpc', 'WerSvc', 'wercplsupport', 'WdiSystemHost', 'WbioSrvc', 'WalletService',
           'WaaSMedicSvc', 'vmvss', 'vmicvss', 'vmicvmsession', 'vmicshutdown', 'vmicrdv', 'vmickvpexchange',
           'vmicheartbeat', 'vmicguestinterface', 'VaultSvc', 'UsoSvc', 'UserManager', 'UmRdpService',
           'TroubleshootingSvc', 'TrkWks', 'TokenBroker', 'Themes', 'TabletInputService', 'SystemEventsBroker',
           'SysMain', 'swprv', 'svsvc', 'StorSvc', 'StateRepository', 'shpamsvc', 'ShellHWDetection', 'SharedAccess',
           'SessionEnv', 'SensorService', 'SENS', 'seclogon', 'SDRSVC', 'SCPolicySvc', 'Schedule', 'ScDeviceEnum',
           'SamSs', 'RetailDemo', 'RemoteAccess', 'RasMan', 'RasAuto', 'PushToInstall', 'ProfSvc', 'PrintNotify',
           'Power', 'PlugPlay', 'PcaSvc', 'NgcSvc', 'Netman', 'Netlogon', 'NcbService', 'NcaSvc', 'NaturalAuthentication',
           'MSiSCSI', 'MixedRealityOpenXRSvc', 'LxpSvc', 'ifsvc', 'LanmanServer', 'KeyIso', 'IpxlatCfgSvc', 'iphlpsvc',
           'lfsvc', 'InstallService', 'IKEEXT', 'HvHost', 'hidserv', 'GraphicsPerfSvc', 'gpsvc', 'FrameServer', 'fhsvc',
           'EntAppSvc', 'embeddedmode', 'EFS', 'Eaphost', 'DsSvc', 'DsmSvc', 'dot3svc', 'dmwappushservice', 'DmEnrollmentSvc',
           'DisplayEnhancementService', 'DiagTrack', 'diagsvc', 'DevQueryBroker', 'DeviceInstall', 'DeviceAssociationService',
           'defragsvc', 'DcomLaunch', 'CscService', 'ClipSVC', 'CertPropSvc', 'camsvc', 'Browser', 'BrokerInfrastructure',
           'BITS', 'BDESVC', 'AxInstSV', 'AudioEndpointBuilder', 'AssignedAccessManagerSvc', 'AppXSvc', 'AppReadiness',
           'AppMgmt', 'Appinfo', 'CcmExec', 'CmRcService', 'smstsmgr', 'lpasvc', 'edgeupdatem', 'edgeupdate',
           'MBAMAgent', 'LSM', 'NetSetupSvc', 'MicrosoftEdgeElevationService', 'DialogBlockingService',
           'MsKeyboardFilter', 'uhssvc')

Get-WmiObject win32_service -Filter "StartName LIKE '%LocalSystem'" | ForEach-Object -Process {
 if (($_.StartMode -ne 'Disabled') -and (!$win10_builtin.Contains($_.Name))) {
   Write-Host Service: $_.Name
   Write-Host Display name: $_.DisplayName
   Write-Host Privilege: $_.StartName
   Write-Host Path: $_.PathName
   Write-Host State: $_.State
   Write-Host StartMode: $_.StartMode
   Write-Host ''
  }
}