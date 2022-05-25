Write-Host "Mountebank Installer"

if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Warning "This setup needs admin permissions. Please run this file as admin."     
    break
}

### Version Check

if (Get-Command node -ErrorAction SilentlyContinue) {
    Try 
    {
        $current_version = (node -v)
    }
    Catch 
    {
        Write-Host "No nodejs version found"
        $current_version = 0
    }    
} 

Write-Host "Node is installed: $current_version"

if ($current_version -eq 0) {
    Write-Warning "Please install node from https://nodejs.org/en/"
} else {
    Write-Host "Checking for Mountebank"
    Try 
    {
        $mountebank = (mb --version)
        Write-Host "Mountebank $mountebank is already installed"
    }
    Catch 
    {
        Write-Host "Install Mountebank"
        npm i -g mountebank
    }

}
