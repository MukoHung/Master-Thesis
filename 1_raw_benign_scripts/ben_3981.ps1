param($java_version)
$java_install_dir = switch($java_version)
{
    8 {"C:\Program Files\Zulu\zulu-8"}
    15 {"C:\Program Files\Zulu\zulu-15"}
    default {"unknown"}
}

if ($java_install_dir -ne "unknown") {
    $old_path=(Get-ChildItem env:Path).value
    
    Set-Item -Path Env:JAVA_HOME -Value "$java_install_dir"
    Set-Item -Path Env:Path -Value "$java_install_dir/bin;$old_path"
    java -version
} else {
    write-host "please give in java version number"
    write-host "example: switch-java 8"
}