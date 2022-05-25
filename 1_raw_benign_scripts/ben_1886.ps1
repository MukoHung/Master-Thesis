param(
    [string]$widget = ""
)

$PSScriptRoot
$zipScript = $PSScriptRoot + "\zip.ps1 -domain test.pcm.com -widget $($widget)"
$copyScript = $PSScriptRoot + "\copy.ps1"

# Start
Write-Host "Import component $($widget) starting..." -ForegroundColor Green
Write-Host ""

# Remove for imports folder
#Write-Host "Removimg component from `Imports\UxPlugins` folder..." -ForegroundColor DarkCyan
Get-ChildItem "C:\Users\Byurchuk\Projects\scribble\ion\LiveBall\src\LiveBall.Web\Areas\Admin\Imports\UxPlugins\ixp-$($widget).zip" -Recurse | Remove-Item -Recurse
Get-ChildItem "C:\Users\Byurchuk\Projects\scribble\ion\LiveBall\src\LiveBall.Web\Areas\Admin\Imports\UxPlugins\$($widget).zip" -Recurse | Remove-Item -Recurse
Write-Host "Component removed from `Imports\UxPlugins` folder [OK]" -ForegroundColor Green

#Remove from global folder
#Write-Host "Removing component from `Global\UxPlugins` folder ..." -ForegroundColor DarkCyan
Get-ChildItem "C:\Users\Byurchuk\Projects\scribble\ion\LiveBall\src\LiveBall.Web\Global\UxPlugins\ixp-$($widget)" -Recurse | Remove-Item -Recurse
Get-ChildItem "C:\Users\Byurchuk\Projects\scribble\ion\LiveBall\src\LiveBall.Web\Global\UxPlugins\$($widget)" -Recurse | Remove-Item -Recurse
Write-Host "Component removed from `Global\UxPlugins` folder [OK]" -ForegroundColor Green

# Run zip
#Write-Host "Zipping..." -ForegroundColor DarkCyan
Invoke-Expression $zipScript
Write-Host "Zip end [OK]" -ForegroundColor Green

#Run copy
#Write-Host "Copying..." -ForegroundColor DarkCyan
Invoke-Expression $copyScript
Write-Host "Copy end [OK]" -ForegroundColor Green

#End
Write-Host ""
Write-Host "Import component $($widget) end [OK]" -ForegroundColor Green

# play signal about and of execution
[system.media.systemsounds]::Exclamation.play()
