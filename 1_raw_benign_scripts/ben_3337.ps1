$arguments=$args[0]
$command="Restart-Computer $arguments"

Write-Host "Command: '$command'"

iex $command

Write-Host "Done"