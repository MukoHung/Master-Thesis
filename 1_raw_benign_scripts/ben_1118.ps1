$git checkout –b temp #makes a new branch from current detached HEAD
$git branch –f master temp #update master to point to the new <temp> branch
$git branch –d temp #delete the <temp> branch
$git push origin master #push the re-established history