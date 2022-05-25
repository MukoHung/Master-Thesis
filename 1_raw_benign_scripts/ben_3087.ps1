function prompt {
	write-host;
	get-location | write-host;
	if (isCurrentDirectoryGitRepository) {
        $status = gitStatus
        
        Write-Host('[') -nonewline -foregroundcolor Yellow
		write-host $status["branch"] -nonewline -foregroundcolor Yellow;
		if ($status["remote"] -ne ""){
			if ($status["behind"] -ne 0){
				write-host " <" -nonewline -foregroundcolor Yellow;
				write-host $status["behind"] -nonewline -foregroundcolor Yellow;
			}
			write-host " " -nonewline -foregroundcolor Yellow;
			if ($status["ahead"] -ne 0){
				write-host $status["ahead"] -nonewline -foregroundcolor Yellow;
				write-host "> " -nonewline -foregroundcolor Yellow;
			}
			write-host $status["remote"] -nonewline -foregroundcolor Yellow;
		}
		             
        Write-Host(']') -foregroundcolor Yellow 
    }
}

function gitStatus {
    $branch = "";
	$remote = "";
	$ahead = 0;
	$behind = 0;

    
	$output = git branch -vv
	
	$output | foreach {
		if ($_ -match "\* (.*?) "){
			$branch = $matches[1];
		}
		if ($_ -match "\* .*\[(.*?)[:\]]"){
			$remote = $matches[1];
		}
		if ($_ -match "\* .* ahead (\d+)"){
			$ahead = $matches[1];
		}
		if ($_ -match "\* .* behind (\d+)"){
			$behind = $matches[1];
		}
	}
    
    return @{"branch" = $branch;
				"remote" = $remote;
				"ahead" = $ahead;
				"behind" = $behind;}
}


# some functions sourced from http://markembling.info/2009/09/my-ideal-powershell-prompt-with-git-integration
# Git functions
# Mark Embling (http://www.markembling.info/)

# Is the current directory a git repository/working copy?
function isCurrentDirectoryGitRepository {
    if ((Test-Path ".git") -eq $TRUE) {
        return $TRUE
    }
    
    # Test within parent dirs
    $checkIn = (Get-Item .).parent
    while ($checkIn -ne $NULL) {
        $pathToTest = $checkIn.fullname + '/.git'
        if ((Test-Path $pathToTest) -eq $TRUE) {
            return $TRUE
        } else {
            $checkIn = $checkIn.parent
        }
    }
    
    return $FALSE
}
# end of Mark Emblings GIT functions
