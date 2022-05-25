# Comparing Firefox, Google Chrome and Internet Explorer memory footprints

# also check: PeakWorkingSet, PrivateWorkingSet, PagedMemorySize etc
# ps is an alias for Get-Process, WS is short for "WorkingSet", -exp for "-expand"
function sumProc($partialName) { ps "$partialName*"  | Measure-Object -prop WS -sum | select -exp Sum }

sumProc firef
sumproc chrome
sumproc iexp
