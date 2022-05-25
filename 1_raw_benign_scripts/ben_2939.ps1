# Windows powershell profile
# To be placed in the Documents\PowerShell folder

set-alias please     git # Let's be polite to our machines, we never know when AI is going to take over 😜

Import-Module posh-git # Helps with auto complete in PowerShell. Run First-Time-Setup if the module is not installed

Import-Module -Name Terminal-Icons # Pretty icons for some commands like ls, https://github.com/devblackops/Terminal-Icons

Set-PoshPrompt -Theme morphism # Set custom theme for OhMyPosh. Run First-Time-Setup if the module is not installed or the theme is not downloaded

function gfa { git fetch --all -p }

function gpc { git pull --prune; git branch -D $(git branch --merged).trim(); }

function Complete-FirstTime-Setup {
	function Install-PoshGit {
		Write-Host "Installing Posh Git PowerShell module, allowing auto-completion and status check for git..."
		Install-Module posh-git -Scope CurrentUser
	}

	function Install-OhMyPosh {
		function Set-OhMyPosh-Theme {
			Write-Host "Downloading Morphism theme for Oh My Posh..."
			$themeAddress = "https://raw.githubusercontent.com/RezaJooyandeh/device-setup/main/PowerShell/oh-my-posh-themes/morphism.omp.json"
			$ohMyPoshThemeFolder = [Environment]::GetFolderPath("MyDocuments") + "\PowerShell\Modules\oh-my-posh\3.158.4\themes"
			Start-BitsTransfer -Source $themeAddress -Destination $ohMyPoshThemeFolder
		}

		https://raw.githubusercontent.com/RezaJooyandeh/device-setup/main/Microsoft.PowerShell_profile.ps1

		Write-Host "Installing Oh My Posh PowerShell module, allowing customization of the command layouts..."
		Install-Module oh-my-posh -Scope CurrentUser
	
		Set-OhMyPosh-Theme
	}

	function Update-WindowsTerminal-Settings {
		Write-Host "Downloading Windows Terminal settings..."
		$terminalSettingsAddress = "https://raw.githubusercontent.com/RezaJooyandeh/device-setup/main/WindowsTerminal/settings.json"
		$windowsTerminalSettingsFolder = [Environment]::GetEnvironmentVariable("LOCALAPPDATA") + "\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState"
		Start-BitsTransfer -Source $terminalSettingsAddress -Destination $windowsTerminalSettingsFolder

		Write-Host "Installing Terminal Icons PowerShell module, making some commands like ls, use fancy icons..."
		Install-Module -Name Terminal-Icons -Repository PSGallery
	}

	Install-PoshGit
	Install-OhMyPosh
	Update-WindowsTerminal-Settings
}
