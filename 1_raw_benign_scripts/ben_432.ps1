##################################################
#resources
##################################################
#http://technet.microsoft.com/en-us/library/cc721886(v=ws.10).aspx
#http://technet.microsoft.com/en-us/library/cc709667(v=ws.10).aspx
##################################################
#resources
##################################################
####################################################################################

## How to change the default operating system entry
## At the command prompt, type:
##     bcdedit /default ID

## The following command sets the specified entry as the default boot manager entry:
bcdedit /default {cbd971bf-b7b8-4885-951a-fa03044f5d71}

####################################################################################

## How to change the boot sequence for the next reboot?
## At the command prompt, type:
##     bcdedit /bootsequence {ID} {ID} {ID} …

## The following command sets the specified operating system as the default for the next restart. After that restart, it will be reset to DISPLAYORDER.
bcdedit /bootsequence {cbd971bf-b7b8-4885-951a-fa03044f5d71}

####################################################################################

## How to list entries of a particular type?
## The /enum command lists entries in the BCD store. To list entries, type: bcdedit /enum [Type]

## Options:
##     active. (default). Lists all entries in the boot manager display order. 
##     Firmware. Lists all firmware applications entries.
##     Bootapp. Lists all boot environment applications entries.
##     Bootmgr. Lists all Boot manager entries.
##     Osloader. Lists all operating system entries.
##     Inherit. Lists all inherit type entries.
##     All. Lists all entries.

## The following command lists all boot manager entries:
bcdedit /enum bootmgr

####################################################################################

## How to set the boot manager display order?
## At the command prompt, type:
##      Bcdedit.exe /display {ID} {ID1} {ID2} …
## or
##      Bcdedit.exe /displayorder {ID} [/addlast|/addfirst|/remove]

## The following command sets three operating system entries in the boot manager display order:
Bcdedit.exe /displayorder {c84b751a-ff09-11d9-9e6e-0030482375e6} {c74b751a-ff09-11d9-9e6e-0030482375e4} {c34b751a-ff09-11d9-9e6e-0030482375e7}

####################################################################################

##How to delete a boot entry?
## The following command deletes the entry with id {802d5e32-0784-11da-bd33-000476eba25f}.
bcdedit /delete {802d5e32-0784-11da-bd33-000476eba25f}