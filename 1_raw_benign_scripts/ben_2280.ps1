# this script locks down some useless features on your windows machine to reduce the attack surface for your windows machine...
# execute the script as "powershell -file lockdown.ps1" (administrator priviledge required)
# you might need to alter te execution-policy to execute this script, but don't forget to secure the execution-policy afterwards :-)
# 2015 - Roel Van Steenberghe roel.vansteenberghe@gmail.com

# the support in windows for ipv6 is a little to great: automatic tunnels are allowed by default, making it a great tool for hackers to create man in the middle attacks...
netsh interface ipv6 6to4 set state state=disabled undoonstop=disabled

# about teredo in a security context: http://www.symantec.com/avcenter/reference/Teredo_Security.pdf
netsh interface teredo set state disabled


netsh interface ipv6 isatap set state state=disabled

# more to come, feel free to add suggestions
