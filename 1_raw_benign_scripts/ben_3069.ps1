$poshToolsPath = "C:\Source\zzUtilities\posh-tools"
if (Test-Path "$poshToolsPath\profile.ps1")
{
    . "$poshToolsPath\profile.ps1"
}

$env:USERINITIALS = 'SEB'
$env:TICKETS_PATH = "${env:OneDrive}\tasks"
$env:NOTES_PATH = "${env:OneDrive}\notes"
Set-Alias cdk Set-TicketLocation
Set-Alias co Open-GitBranch



# $env:EVESTMENT_HOME = "C:\Source"
# $SRC = $env:EVESTMENT_HOME
# $DEV_TOOLS = "${env:EVESTMENT_HOME}\zzUtilities\DeveloperTools"
# $PRODUCTION = "${env:EVESTMENT_HOME}\Production"
# $ANALYTICS = "${PRODUCTION}\Analytics"
# $SHARED_API = "${PRODUCTION}\SharedApi"
# $LEGACY = "${PRODUCTION}\Legacy"
# ${INPUT} = "${PRODUCTION}\Input"
# $ROUNDHOUSE = "${PRODUCTION}\Roundhouse"
# $DATA_OPS = "${PRODUCTION}\DataOperations"
# $PLATFORM = "${PRODUCTION}\Platform"
# $DISTRIBUTED_DATASETS = "${PLATFORM}\distributed-datasets"
# $TERRAFORM = "${PRODUCTION}\Terraform"
# $INFRASTRUCTURE = "${TERRAFORM}\aws_infrastructure"
# $MICROSERVICES = "${PRODUCTION}\Microservices"
# $ALERTS = "${MICROSERVICES}\alerts"
# $CURRENCY = "${MICROSERVICES}\currency"
# $PRODUCTS = "${MICROSERVICES}\products"

# # Executables
# $env:DEVENV_PATH = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2017\Enterprise\Common7\IDE\devenv.exe"
# $env:SSMS_PATH = "${env:ProgramFiles(x86)}\Microsoft SQL Server\120\Tools\Binn\ManagementStudio\Ssms.exe"
# $env:JMETER_HOME = "$env:HOME\usr\bin\apache-jmeter-5.0"

# # Environment variables to support development
# $env:DATAOPS_HOME = "${env:EVESTMENT_HOME}\Production\DataOperations\src"
# $env:PSModulePath = "${env:EVESTMENT_HOME}\Production\DataOperations\src\Modules;${env:PSModulePath}"
# $env:PSModulePath = "${env:EVESTMENT_HOME}\Production\DataOperations\packages;${env:PSModulePath}"
# $env:PSModulePath = "${env:EVESTMENT_HOME}\zzUtilities\DeveloperTools\modules;${env:PSModulePath}"
# $env:PSModulePath = "${env:EVESTMENT_HOME}\TeamMembers\seb-jmeter;${env:PSModulePath}"

# $env:USERINITIALS = 'SEB'
# $OHOME = "${HOME}\OneDrive - eVestment"
# $TASKS = "${USR}\tasks"

# Import-Module Git

# if (Test-Path "${env:HOME}\usr\.jira-token")
# {
#     $tokenSS = Get-Content "${env:HOME}\usr\.jira-token" | ConvertTo-SecureString
#     $env:JiraToken = (New-Object pscredential 'x', $tokenSS).GetNetworkCredential().Password
# }

# Set-Alias rhdeploy New-RoundhouseDeployScript
# Set-Alias rhmigration New-RoundhouseMigrationScript
# Set-Alias rhobject New-RoundhouseObjectScript
# Set-Alias tf Invoke-Terraform
# Set-Alias vs Start-VisualStudio

# Set-Alias cdk Set-TicketLocation
# function cds { Set-Location $env:EVESTMENT_HOME }
# function cdo { Set-Location $OHOME }
# function cda { Set-Location $ANALYTICS }
# function cdsa { Set-Location $SHARED_API }
# function cdl { Set-Location $LEGACY }
# function cdr { Set-Location $ROUNDHOUSE }
# function cdd { Set-Location $DATA_OPS }
# function cdpl { Set-Location $PLATFORM }
# function cddd { Set-Location $DISTRIBUTED_DATASETS }
# function cdt { Set-Location $INFRASTRUCTURE }
# function cdm { Set-Location $MICROSERVICES }
# function cdc { Set-Location $CURRENCY }
# function cdp { Set-Location $PRODUCTS }

# function Start-PullAll { Push-Location ${DEV_TOOLS}; .\GitPullAndUpdate.bat; Pop-Location }
# function Start-BuildAll { Push-Location ${DEV_TOOLS}; .\CompileAll.bat; Pop-Location }
# function Start-BuildAnalytics { Push-Location ${ANALYTICS}; .\.team\shell\build.ps1; Pop-Location }
# function Start-BuildApi { Push-Location ${SHARED_API}; .\.team\shell\build.ps1; Pop-Location }
# function Start-MessageHandler { . ${SHARED_API}\eA.Shared.API.Service\bin\eA.Shared.API.Service.exe }
# function Reset-IIS { Start-ProcessAsAdmin { iisreset.exe } }
# function Update-IISRedirect { Invoke-Item $SRC\ASP\Web.config }