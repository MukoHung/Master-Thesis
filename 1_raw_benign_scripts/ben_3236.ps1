@echo off
setlocal EnableDelayedExpansion
set blacklistdir=blacklists
set reportsdir=reports
set blacklists=
for %%f in (%blacklistdir%/*) do (
	echo Searching %blacklistdir%/%%f ...
	set blacklists=%%blacklists %blacklistdir%/%%f
)
echo %blacklists%
findstr /L /G:%blacklistdir%/%%f 