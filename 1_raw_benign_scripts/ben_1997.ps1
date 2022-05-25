# WINDOWS
# =======
# This assumes you already have chocolatey installed:
# From cmd.exe:
#   @powershell -NoProfile -ExecutionPolicy unrestricted -Command "iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))" && SET PATH=%PATH%;%systemdrive%\chocolatey\bin
# From powershell:
#   iex ((new-object net.webclient).DownloadString('https://chocolatey.org/install.ps1'))
#
# This assumes you have vagrant already installed:
#   cinst vagrant
# or (for specific version):
#   cinst vagrant -version 1.2.7
# NOTE: It really needs to be 1.2.7-ish
#
# This assumes you already have virtualbox installed:
#   cinst virtualbox
#
# Check your ruby version:
#   ruby -v
# if you don't have 1.9.3 installed, install it with the command below:
#   cinst ruby -version 1.9.3.44800
# once installed, please restart the command line. This is important, so don't miss it.
#
# do you have Dev Kit installed?
#   cinst ruby.devkit
# =======

# OSX / Linux
# ===========
# You should be ready if you have vagrant installed. Make sure you are using the offical installer 
#  and NOT the deprecated vagrant gem.
# ===========


# any system
gem install bundler

git clone https://github.com/WinRb/vagrant-windows.git vagrant-windows
cd vagrant-windows
git checkout -t origin/vagrant-1.2
bundle install
bundle exec rake
vagrant plugin install pkg/vagrant-windows-1.2.0.gem