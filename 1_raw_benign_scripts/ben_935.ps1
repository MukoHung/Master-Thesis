# Crawl your Android device attached via usb with PowerShell
The PowerShell script Crawl_Android.ps1 is capable of crawling your Android device when it is attached via usb. 
Just execute Crawl_Android.ps1 and select the device from the menu.

# Limited file details
What I found out is that the Shell Namespace API does not provide a lot of details of the file. It is limited to only a couple of fields that are relevant for the 
Windows Explorer GUI. 
Strangely, a byte-oriented filesize field is not part of it. It only contains a summarized version, e.g. 4 kB or 10 MB. After futher investigation, I noticed that 
Windows Explorer has to make a local temporary copy to get all the details in order to populate the information pane. That's why most operations are so slow!
