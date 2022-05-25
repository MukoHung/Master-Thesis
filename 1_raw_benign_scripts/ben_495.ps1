param(
    [string] $target="templates",
    [string] $platform="x64"
)


# 32-bit compile or 64-bit compile
if ($platform -eq "x64") {
    Write-Host "Configuring for 64-bit..."
    vcvarsall x86_amd64
}
else {
    Write-Host "Configuring for 32-bit..."
    vcvarsall x86
}


# The actual build functions
function build_editor {
    scons platform=windows
}


function build_templates {
    scons platform=windows tools=no target=release
    scons platform=windows tools=no target=release_debug
}


# build driver
if ($target -eq "editor") {
    Write-Host "Building editor..."
    build_editor
}
elseif ($target -eq "templates") {
    Write-Host "Building templates..."
    build_templates
}
elseif ($target -eq "all") {
    Write-Host "Building all..."
    build_editor
    build_templates
}
