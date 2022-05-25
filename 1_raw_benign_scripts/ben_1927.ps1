# NOTE: This is a near-1:1 translation of the installer script provided at
# https://getcomposer.org/doc/faqs/how-to-install-composer-programmatically.md
# to Windows PowerShell from UNIX sh/bash.

# This requires php.exe's containing folder to be on the PATH, and will also
# create a batch file for easy execution of Composer from cmd or Powershell.

[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$sigRequest = Invoke-WebRequest https://composer.github.io/installer.sig
$EXPECTED_SIGNATURE = [System.Text.Encoding]::UTF8.GetString($sigRequest.Content).Trim()
php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
$ACTUAL_SIGNATURE = $(php -r "echo hash_file('sha384', 'composer-setup.php');")

if ($EXPECTED_SIGNATURE -ne $ACTUAL_SIGNATURE) {
	Write-Error "ERROR: Invalid installer signature"
	Remove-Item composer-setup.php
	exit 1
}

php .\composer-setup.php --quiet
$RESULT = $LASTEXITCODE
Remove-Item composer-setup.php
if (Test-Path composer.phar) {
	Write-Output "@`"$((Get-Command php).Source)`" `"%~dp0composer.phar`" %*" > composer.bat
}
exit $RESULT
