$A_xml = ("A-file.xml")

$B_xml = ("B-file.xml")

Compare-Object -ReferenceObject (Get-Content $A_xml) -DifferenceObject (Get-Content $B_xml)