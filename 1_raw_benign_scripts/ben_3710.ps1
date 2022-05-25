# Most straighforward way I can think of
# 2 pairs of curly braces and a single semicolon for the calculated OSVERSION property

Import-Csv .\input.csv |Select-Object -Property MACHINENAME,@{Label='OSVERSION';Expression={(Get-WmiObject Win32_OperatingSystem -ComputerName $_.MACHINENAME).Caption}} | Export-Csv .\output.csv -NoTypeInformation