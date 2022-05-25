#NOTE: This script is based on the Microsoft provided guidance example at
#      https://www.windowsazure.com/en-us/develop/net/common-tasks/continuous-delivery/.

Param(  
  	[parameter(Mandatory=$true)]
		$serviceName,
        [parameter(Mandatory=$true)]
		$storageAccountName,
		[parameter(Mandatory=$true)]
		$storageAccountKey,
		[parameter(Mandatory=$true)]
        $cloudConfigLocation,
		[parameter(Mandatory=$true)]
		$packageLocation,
        $slot = "Staging",
        $deploymentLabel = $null,
        $timeStampFormat = "g",
        $alwaysDeleteExistingDeployments = 1,
        $enableDeploymentUpgrade = 1,
		[parameter(Mandatory=$true)]		
		$selectedSubscription,
		$thumbprint,
		$subscriptionId,
		$location
     )

function SuspendDeployment()
{
    write-progress -id 1 -activity "Suspending Deployment" -status "In progress"
    Write-Output "$(Get-Date –f $timeStampFormat) - Suspending Deployment: In progress"

	$suspend = Set-AzureDeployment -Slot $slot -ServiceName $serviceName -Status Suspended

    write-progress -id 1 -activity "Suspending Deployment" -status $opstat
    Write-Output "$(Get-Date –f $timeStampFormat) - Suspending Deployment: $opstat"
}

function DeleteDeployment()
{
    SuspendDeployment

    write-progress -id 2 -activity "Deleting Deployment" -Status "In progress"
    Write-Output "$(Get-Date –f $timeStampFormat) - Deleting Deployment: In progress"

    $removeDeployment = Remove-AzureDeployment -Slot $slot -ServiceName $serviceName
    Write-Output "$(Get-Date –f $timeStampFormat) - Deleting Deployment: $opstat"

    sleep -Seconds 10
}

function UploadPackage()
{
	# As of the Windows Azure PowerShell cmdlets v0.6.11, there is no support for uploading files to blob storage.
	# The New-AzureDeployment cmdlet requires the .cspkg file to be in blob storage. To work around this current limitation,
	# use the Cerebrata Powershell cmdlets (http://www.cerebrata.com/products/azure-management-cmdlets/introduction)
	$blobFile = Get-ChildItem $packageLocation
	$script:packageBlob = Import-File -File $packageLocation -BlobContainerName "mydeployments" -BlobName $blobFile.Name -DisplayProgress  `
 -AccountName $storageAccountName -AccountKey $storageAccountKey
}

function Publish()
{	
	CreateService
	
    $deployment = Get-AzureDeployment -ServiceName $serviceName -Slot $slot
    if ($deployment -eq $null)
    {
        write-host "No deployment is detected. Creating a new deployment. "
    }
	
    #check for existing deployment and then either upgrade, delete + deploy, or cancel according to $alwaysDeleteExistingDeployments and $enableDeploymentUpgrade boolean variables
    if ($deployment.Name -ne $null)
    {
        switch ($alwaysDeleteExistingDeployments)
        {
            1 
            {		
				UploadPackage
			
                switch ($enableDeploymentUpgrade)
                {
                    1
                    {
                        Write-Output "$(Get-Date –f $timeStampFormat) - Deployment exists in $servicename.  Upgrading deployment."
                        UpgradeDeployment
                    }
                    0  #Delete then create new deployment
                    {
                        Write-Output "$(Get-Date –f $timeStampFormat) - Deployment exists in $servicename.  Deleting deployment."
                        DeleteDeployment
                        CreateNewDeployment

                    }
                } # switch ($enableDeploymentUpgrade)
            }
            0
            {
                Write-Output "$(Get-Date –f $timeStampFormat) - ERROR: Deployment exists in $servicename.  Script execution cancelled."
                exit
            }
        }
    } else
	{
			UploadPackage
            CreateNewDeployment
    }
}

function CreateNewDeployment()
{
    write-progress -id 3 -activity "Creating New Deployment" -Status "In progress"
    Write-Output "$(Get-Date –f $timeStampFormat) - Creating New Deployment: In progress"

    $newdeployment = New-AzureDeployment -Verbose -Slot $slot -Package $packageBlob.BlobUrl -Configuration $cloudConfigLocation -label $deploymentLabel -ServiceName $serviceName -ErrorVariable err -ErrorAction continue
	if ($err.count -ne 0)
	{
		Write-Error "$(Get-Date –f $timeStampFormat) - ERROR: Deployment creating new deployment in $servicename. Script execution cancelled."
        exit 1
	}
	
    StartInstances
}

function CreateService()
{
	$svc = Get-AzureService -ServiceName $servicename
	if ($svc -eq $null)
	{
		New-AzureService -ServiceName $servicename -Location $location
	}
}

function UpgradeDeployment()
{
    write-progress -id 3 -activity "Upgrading Deployment" -Status "In progress"
    Write-Output "$(Get-Date –f $timeStampFormat) - Upgrading Deployment: In progress"

	Set-AzureDeployment -Upgrade -ServiceName $serviceName -Mode Auto -Label $deploymentLabel -Package $packageBlob.BlobUrl -Configuration $cloudConfigLocation -Slot $slot -Force
	
	StartInstances
}

function StartInstances()
{
#    write-progress -id 4 -activity "Starting Instances" -status "In progress"
#    Write-Output "$(Get-Date –f $timeStampFormat) - Starting Instances: In progress"
#
#    $run = Set-AzureDeployment -Slot $slot -ServiceName $serviceName -Status Running
    $deployment = Get-AzureDeployment -ServiceName $serviceName -Slot $slot
    $oldStatusStr = @("") * $deployment.RoleInstanceList.Count

    while (-not(AllInstancesRunning($deployment.RoleInstanceList)))
    {
        $i = 1
        foreach ($roleInstance in $deployment.RoleInstanceList)
        {
            $instanceName = $roleInstance.InstanceName
            $instanceStatus = $roleInstance.InstanceStatus

			# Did the status change?
            if ($oldStatusStr[$i - 1] -ne $roleInstance.InstanceStatus)
            {
                $oldStatusStr[$i - 1] = $roleInstance.InstanceStatus
                Write-Output "$(Get-Date –f $timeStampFormat) - Starting Instance '$instanceName': $instanceStatus"
            }

            write-progress -id (4 + $i) -activity "Starting Instance '$instanceName'" -status "$instanceStatus"
            $i = $i + 1
        }

        sleep -Seconds 1

        $deployment = Get-AzureDeployment -ServiceName $serviceName -Slot $slot
    }

    $i = 1
    foreach ($roleInstance in $deployment.RoleInstanceList)
    {
        $instanceName = $roleInstance.InstanceName
        $instanceStatus = $roleInstance.InstanceStatus

        if ($oldStatusStr[$i - 1] -ne $roleInstance.InstanceStatus)
        {
            $oldStatusStr[$i - 1] = $roleInstance.InstanceStatus
            Write-Output "$(Get-Date –f $timeStampFormat) - Starting Instance '$instanceName': $instanceStatus"
        }

        write-progress -id (4 + $i) -activity "Starting Instance '$instanceName'" -status "$instanceStatus"
        $i = $i + 1
    }

	$deployment = Get-AzureDeployment -ServiceName $serviceName -Slot $slot
    $opstat = $deployment.Status

    write-progress -id 4 -activity "Starting Instances" -status $opstat
    Write-Output "$(Get-Date –f $timeStampFormat) - Starting Instances: $opstat"
}

function AllInstancesRunning($roleInstanceList)
{
    foreach ($roleInstance in $roleInstanceList)
    {
		if ($roleInstance.InstanceStatus -ne "ReadyRole")
        {
            return $false
        }
    }

    return $true
}

cls
Write-Output "$(Get-Date –f $timeStampFormat) - Windows Azure Cloud App deploy script started."

Write-Host "Service Name = $serviceName"
Write-Host "Storage Account = $storageAccountName"
Write-Host "Storage Account Key = $storageAccountKey"
Write-Host "Configuration File = $cloudConfigLocation"
Write-Host "Package File = $packageLocation"
Write-Host "Deployment Slot = $slot"
Write-Host "Label = $deploymentLabel"
Write-Host "Timestamp Format = $timeStampFormat"
Write-Host "Delete Existing Deployment = $alwaysDeleteExistingDeployments"
Write-Host "Perform Upgrade = $enableDeploymentUpgrade"
Write-Host "Subscription Name = $selectedSubscription"
Write-Host "Subscription Id = $subscriptionId"
Write-Host "Management Certificate Thumbprint = $thumbprint"
Write-Host "Deployment Region = $location"

$DebugPreference = 'SilentlyContinue'
$script:packageBlob = ""

# Set the path to the Windows Azure management certificate.
# For TFS build servers, this is often LocalMachine\My.
# For local development, this can be either LocalMachine\My or CurrentUser\My (really any place you can access).
$certPath = "cert:\CurrentUser\My\" + $thumbprint
Write-Host "Using certificate: " $certPath

$cert = Get-Item $certPath
if ($cert -eq $null)
{
	Write-Error "Unable to locate specified certificate by thumbprint."
	exit 1
}

# Manually set the Windows Azure subscription details.
$subscriptionTemp = Get-AzureSubscription | Where-Object {$_.SubscriptionName -eq $selectedSubscription}
if ($subscriptionTemp -eq $null)
{
	Set-AzureSubscription -CurrentStorageAccount $storageAccountName -SubscriptionName $selectedSubscription -Certificate $cert `
	-SubscriptionId $subscriptionId
}

# Clear out any previous Windows Azure subscription details in the current context (just to be safe).
Select-AzureSubscription -Clear

# Select (by friendly name entered in the 'Set-AzureSubscription' cmdlet) the Windows Azure subscription to use.
Select-AzureSubscription $selectedSubscription


# Build the label for the deployment. Currently using the current time. Can be pretty much anything.
if ($deploymentLabel -eq $null)
{
	$currentDate = Get-Date
	$deploymentLabel = $serviceName + " - v" + $currentDate.ToUniversalTime().ToString("yyyyMMdd.HHmmss")
}
Write-Output "$(Get-Date –f $timeStampFormat) - Preparing deployment of $deploymentLabel for Subscription ID $subscriptionId."

# Execute the steps to publish the package.
Publish

$deployment = Get-AzureDeployment -slot $slot -serviceName $serviceName
$deploymentUrl = $deployment.Url
$deploymentId = $deployment.DeploymentId

Write-Output "$(Get-Date –f $timeStampFormat) - Creating New Deployment, Deployment ID: $deploymentId."
Write-Output "$(Get-Date –f $timeStampFormat) - Created Cloud App with URL $deploymentUrl."
Write-Output "$(Get-Date –f $timeStampFormat) - Windows Azure Cloud App deploy script finished."