Set-ExecutionPolicy Unrestricted;
iex ((New-Object System.Net.WebClient).DownloadString('http://boxstarter.org/bootstrapper.ps1'));
get-boxstarter -Force;
Install-BoxstarterPackage -PackageName 'https://gist.githubusercontent.com/OALabs/afb619ce8778302c324373378abbaef5/raw/4006323180791f464ec0a8a838c7b681f42d238c/oalabs_x86vm.ps1';