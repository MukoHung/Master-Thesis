# (1) equivalent of Linux `mkdir` command
New-Item -ItemType Directory -Force $home/projects/windevkit/jobdsl

# (2) equivalent of Linux `cd` command
Set-Location $home/projects/windevkit

# (3) equivalent of Linux `touch` command
@"
Dockerfile
docker-compose.yml
jenkins.yaml
jobs.yaml
plugins.txt
jobdsl/hello_flask.groovy
jobdsl/hello_sinatra.groovy
"@.Split([Environment]::NewLine) | `
  ForEach-Object { New-Item -ItemType File -Name $_ }
