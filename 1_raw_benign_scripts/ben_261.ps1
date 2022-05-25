# -*- coding: sjis -*-

write-host "This is" $myInvocation.myCommand.path

# $env:HOME の設定
if (-not $env:HOME) {
    $env:HOME = $home
}
(get-psProvider filesystem).home = $env:HOME

#
# .profile.ps の読み込み
# 
if (test-path "$env:HOME\.profile.ps1" -pathType leaf) {
    $myProfile = "$env:HOME\.profile.ps1"
} elseif (test-path "$env:HOME\configs\powershell\.profile.ps1" -pathType leaf) {
    $myProfile = "$env:HOME\configs\powershell\.profile.ps1"
}

if ($myProfile) {
    write-host "  loading" $myProfile
    . $myProfile
}
