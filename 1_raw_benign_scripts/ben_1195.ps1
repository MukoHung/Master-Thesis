(& docker images --all --quiet --filter 'dangling=true') | Foreach-Object {
    & docker rmi $_ | out-null
}

(& docker ps --quiet --filter 'status=exited' ) | Foreach-Object {
    & docker rm $_ | out-null
}
