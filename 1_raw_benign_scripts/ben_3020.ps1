$name = Read-Host “What is your name?” #Get name from CLI
$quest = Read-Host “What is your quest?” #Get quest from CLI
$windowObject = new-object -comobject wscript.shell #Create windows message box object
$output = $windowObject.popup(“Hello $name.`nYour quest sounds exciting!”,0,”Quest: $quest”,1) #Display the message