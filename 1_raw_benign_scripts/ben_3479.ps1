#Am I the only one using CIM?
gcim Win32_OperatingSystem -cn Win81|ft PSC*,*aj*,V*,@{n='BIOSSerial';e={(gcim win32_Bios -cn $_.csname).SerialNumber}}