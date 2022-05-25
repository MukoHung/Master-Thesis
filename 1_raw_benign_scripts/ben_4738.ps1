$versions = Invoke-WebRequest -Uri "https://ziglang.org/download/index.json" | ConvertFrom-Json

$zig_zip_url = $versions.master.'x86_64-windows'.tarball 

$zig_master_version = $versions.master.version

$zig_current_folder = "zig-windows-x86_64-${zig_master_version}"

Write-Host "===== URL: ${zig_zip_url}"

if ( Test-Path ".\${zig_current_folder}" ) {
    Write-Host "===== Current Version already installed"
} else {
    Invoke-WebRequest -Uri $zig_zip_url -OutFile "./${zig_current_folder}.zip"
    Expand-Archive -Path "./${zig_current_folder}.zip" -Destination '.'
}

$old_path = [Environment]::GetEnvironmentVariable("Path", "User").split(";")

for ( $i = 0; $i -lt $old_path.Length; $i++ ) {
    if ( $old_path[$i] -Like "*zig-windows-x86_64-*" ) {
        $old_path[$i] = Resolve-Path -Path "./${zig_current_folder}"
        Write-Host "New path: " $old_path[$i] 
    }
}

[Environment]::SetEnvironmentVariable(
   "Path",
   $old_path -join ";",
   "User"
)



