. { iwr -useb https://boxstarter.org/bootstrapper.ps1 } | iex; get-boxstarter -Force

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

Install-BoxstarterPackage -PackageName https://gist.github.com/jilljurgens/87f073193ab2f631f2f166e8fbdf6b16 