<#
    .EXAMPLE  .\Install-Com.ps1 -applicationName "test.application" `
                               -applicationIdentity "someuser" `
                               -componentBinPath "C:\where\is\your\dll\some.dll"
    
                               This will install 1 COM+ component to an application
                               If you have 1 application with 3 components
                               - call this 3 times for each COM+ Component dll path
#>

param(
    [string]$applicationName, 
    [string]$applicationIdentity = "nt authority\localservice",
    [string]$componentId = "8418ea80-e614-4ff0-9bbc-36ba89d0336d", # test app Id in a .net lib i made
    [string]$componentBinPath
)

# Validation 
if ($true -eq [System.String]::IsNullOrEmpty($applicationName))
{
    Write-Host "applicationName is required";
    exit;
}

if ($true -eq [System.String]::IsNullOrEmpty($applicationIdentity))
{
    Write-Host "applicationIdentity is required";
    exit;
}

if ($true -eq [System.String]::IsNullOrEmpty($componentBinPath))
{
    Write-Host "componentBinPath is required";
    exit;
}

$pathValid = Test-Path $componentBinPath;
if ($false -eq $pathValid)
{
    Write-host "Invalid bin path";
    exit;
}


$server = New-Object -comobject COMAdmin.COMAdminCatalog
$apps = $server.GetCollection("Applications");
$apps.Populate();

try
{
    $isAlreadyInstalled = ($apps | Where-Object { $_.Name -eq $applicationName} );
    if ($true -eq $isAlreadyInstalled)
    {
        Write-Host "$applicationName is already installed."
    }
    else
    {
        Write-Host "installing $applicationName."

        # install application
        $app = $apps.Add();
        $app.Value("Name") = $applicationName;
        $app.Value("ApplicationAccessChecksEnabled") = 0;
        $app.Value("Identity") = $applicationIdentity;
        #
        # Set the password here 
        #
        #$app.Value("Password") = "{PASSWORD}"
        $results = $apps.SaveChanges();
        Write-Host $results;
    }
}
catch
{
    Write-Host "Error setting up Application";
    Write-Error $Error[0];
    exit;
}

# setup components 
try
{

    $appContext = ($apps | Where-Object { $_.Name -eq $applicationName} );
    # doc : https://docs.microsoft.com/en-us/windows/desktop/api/ComAdmin/nf-comadmin-icomadmincatalog-installcomponent
    $installResults = $server.InstallComponent($appContext.Key, $componentBinPath, "", "");
    Write-Host $installResults;
    $results = $apps.SaveChanges();
    Write-Host $results;
}
catch
{
    Write-Host "Error installing component";
    Write-Error $Error[0];
    exit;
}

Write-Host "Complete";