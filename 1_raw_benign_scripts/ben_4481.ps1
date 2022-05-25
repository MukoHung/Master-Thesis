# Script for batch installing Visual Studio Code extensions
# Specify extensions to be checked & installed by modifying $extensions

$extensions =
    # Look & Feel
    "azemoh.one-monokai",
    "emmanuelbeziat.vscode-great-icons",
    # Editing
    "HookyQR.beautify",
    "ow.vscode-subword-navigation",
    "formulahendry.auto-close-tag",
    "formulahendry.auto-rename-tag",
    # Language support
    "ms-vscode.csharp",
    # Extra functionality
    "humao.rest-client",
    "cssho.vscode-svgviewer"

$cmd = "code --list-extensions"
Invoke-Expression $cmd -OutVariable output | Out-Null
$installed = $output -split "\s"

foreach ($ext in $extensions) {
    if ($installed.Contains($ext)) {
        Write-Host $ext "already installed." -ForegroundColor Gray
    } else {
        Write-Host "Installing" $ext "..." -ForegroundColor White
        code --install-extension $ext
    }
}