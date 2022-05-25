Set-PSReadlineOption -BellStyle None
# Clone `https://github.com/dahlbyk/posh-git.git` to C:\Gits
Import-Module 'C:\Gits\posh-git\src\posh-git.psd1'

set-executionpolicy Unrestricted process
$baseDir = Split-Path -parent $MyInvocation.MyCommand.Definition
#. "$baseDir\hand.ps1"

# General actions
function edit ($file) { & "${env:ProgramFiles(x86)}\Notepad++\notepad++.exe" $file }
function vim () { & "${env:ProgramFiles(x86)}\Vim\vim82\gvim.exe" $args }
function sln { ls -Filter "*.sln" | select -first 1 | %{& ".\$_"} }
function explore { "explorer.exe `"$(pwd)`"" | iex }
function wipe { $Host.UI.RawUI.ForegroundColor = "white"; $Host.UI.RawUI.BackgroundColor = "black"; clear; }
function touch ($file) { echo "" >> $file; }

#
# Shell environment
#
function swapd() { # swap between two directories (recreates "pushd +1" from *nix)
	if ((Get-Location -Stack).Count -eq 0) {return}
	$swapd_a = pwd;	popd; $swapd_b = pwd;
	cd $swapd_a; pushd $swapd_b
}
set-alias which where.exe

# Prompt with directory stack
function prompt {
    $prompt_dir_stack = ""
    $prompt_cd = "$(Get-Location)"

    $host.ui.rawui.WindowTitle = $prompt_cd
    $stackStr = ""
    $timeStr = (Get-Date).ToLongTimeString()
    if ((Get-Location -Stack).Count -gt 0) {
        $stackStr = "$((Get-Location -Stack).Peek()) +$((Get-Location -Stack).Count - 1)"
    }

    Write-Host "$timeStr  $stackStr" -fore "darkgray"
    "$(get-location)> "
}

# Git helpers
function gti() { echo "Vrooom!"; iex "git $args" }
function ga() { git add -A }
function gs() { git status }
function gas() { git add -A; git status }
function gresetunstaged() { git stash -k -u; git stash drop }
function gcp($msg) { git commit -m "$msg"; git push }
function get() { git pull --ff-only }
function upmaster() { git checkout master; git pull --ff-only }
function glog() { clear; git --no-pager log --oneline --graph -n 20 --all --format=format:"%<(60,trunc)%s %Cgreen%<(40,ltrunc)%d%Creset" --date-order; echo "`n" }
function gf() { git fetch --all --prune; glog }
function clean_node() { git clean -xdf -e "node_modules" -e "bower_components" }
function gco($branch) { git checkout --track -b "$branch" "origin/$branch" }
function rev($branch) {
    $currentBranch = git rev-parse --abbrev-ref HEAD
    if (-not ($currentBranch -eq "master")) { echo "Not on master"; return }
    git merge --no-ff --no-commit "origin/$branch"
}

function pullrev($reference){ # Review code in a Gerrit system
    if ([string]::IsNullOrEmpty($reference)) {
        echo "Reference needed. From Gerrit URL 92115/3 -> refs/changes/15/92115/3`nABCDE -> DE/ABCDE/rev"
        return
    }
    $currentBranch = git rev-parse --abbrev-ref HEAD;
    if (-not ($currentBranch -eq "master")) { echo "You need to be on 'master' to review"; return }
    git fetch origin $reference;
    git merge --no-ff --no-commit FETCH_HEAD;
}

function pushrev() { # send a commit for gerrit review
    git push origin HEAD:refs/for/master
}


# Git maintainance
function gdelete_local_merged() {git branch --merged | ?{-not ($_ -like "*master")} | ?{-not ($_.StartsWith("*"))} | %{git branch -d $_.trim()}}
function gdelete_remote_merged($remote) {
    git branch -r --merged "$remote/master" |
    %{$_.trim()} |
    ?{$_.StartsWith($remote)} |
    ?{-not ($_ -match "master")} |
    ?{-not ($_ -match "HEAD")} |
    %{$_.split("/")[1]} |
    %{ git push $remote :"$_" }
}

# Nodejs helpers
function cover() { istanbul cover C:\Users\iainb\AppData\Roaming\npm\node_modules\mocha\bin\_mocha -- -R spec }
function buildSingle($moduleName) { gulp compile -p !$moduleName}
function buildTree($moduleName) { gulp compile -p $moduleName}

#Enable-GitColors
$Host.UI.RawUI.ForegroundColor = "white"; $Host.UI.RawUI.BackgroundColor = "black";

cd /
 
#$__old_path = $env:path
#$env:path += ";${env:ProgramFiles}\Git\bin;${env:ProgramFiles}\Git\usr\bin;" # temp add git-bin to path
#Start-SshAgent -Quiet
#$env:path = $__old_path
#Remove-Variable __old_path
 

# Chocolatey profile
$ChocolateyProfile = "$env:ChocolateyInstall\helpers\chocolateyProfile.psm1"
if (Test-Path($ChocolateyProfile)) {
  Import-Module "$ChocolateyProfile"
}
