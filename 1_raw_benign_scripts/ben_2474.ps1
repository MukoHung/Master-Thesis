<#
Recursively move all files in C:\SourceDir into C:\Destination
Assumes C:\Destination exists already, or there could be problems
#>

Move-Item -Path "C:\SourceDir\*" -Destination "C:\Destination"