$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Definition

function Initialize-Tool {
    param (
        [System.String]$ToolName
    )

    if (& "$ScriptPath/Check-Command-Exists.ps1" $ToolName) {
        Write-Host "${ToolName}: Found" -ForegroundColor Green
    }
    else {
        # Install missing tool
        Write-Host "${ToolName}: Not Found... Installing" -ForegroundColor Yellow
        & "$ScriptPath/Install-$ToolName.ps1"

        # Reload PATH
        $env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User") 

        # Check if installation succeded
        if (& "$ScriptPath/Check-Command-Exists.ps1" $ToolName) {
            Write-Host "$ToolName installation succeded" -ForegroundColor Green
        }
        else {
            Write-Host "$ToolName installation failed" -ForegroundColor Red
        }
    }
}

# Create Temporary Directory
New-Item -ItemType Directory -Force -Path "$ScriptPath/temp" | Out-Null

Initialize-Tool -ToolName CMake
Initialize-Tool -ToolName GCC
