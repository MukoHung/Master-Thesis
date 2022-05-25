## Set host file so the instance knows where to find chef-server
$hosts = "1.2.3.4 hello.example.com"
$file = "C:\Windows\System32\drivers\etc\hosts"
$hosts | Add-Content $file

## Download the Chef client
$clientURL = "https://packages.chef.io/files/stable/chef/12.19.36/windows/2012/chef-client-12.19.36-1-x64.msi"
$clientDestination = "C:\chef-client.msi"
Invoke-WebRequest $clientURL -OutFile $clientDestination

## Install the chef-client
Start-Process msiexec.exe -ArgumentList @('/qn', '/lv C:\Windows\Temp\chef-log.txt', '/i C:\chef-client.msi', 'ADDLOCAL="ChefClientFeature,ChefSchTaskFeature,ChefPSModuleFeature"') -Wait

## Create first-boot.json
$firstboot = @{
   "run_list" = @("role[base]")
}
Set-Content -Path c:\chef\first-boot.json -Value ($firstboot | ConvertTo-Json -Depth 10)

## Create client.rb
$nodeName = "lab-win-{0}" -f (-join ((65..90) + (97..122) | Get-Random -Count 4 | % {[char]$_}))

$clientrb = @"
ssl_verify_mode        :verify_none
verify_api_cert        false
chef_server_url        'https://chef-server/organizations/my-org'
validation_client_name 'validator'
validation_key         'C:\chef\validator.pem'
node_name              '{0}' 
"@ -f $nodeName

Set-Content -Path c:\chef\client.rb -Value $clientrb

## Download key
$keyURL = "https://s3/validator.pem"
$keyDestination = "C:\chef\validator.pem"
Invoke-WebRequest $keyURL -OutFile $keyDestination

## Run Chef
C:\opscode\chef\bin\chef-client.bat -j C:\chef\first-boot.json