# Fix USB connection from Raspberry Pi on Windows
Following this tutorial https://gist.github.com/gbaman/975e2db164b3ca2b51ae11e45e8fd40a, many had problems connecting their Raspberry Pi's via OTG on Windows.
Unfortunately, most of the linked drivers aren't available anymore.

## Why doesn't it work out of the box?
As far as I understood, Windows only accepts signed drivers. 
It works with drivers from e.g. Acer though, because they provide signed drivers.
The below tutorial shows how you can create/sign your own driver.

## Create your own driver
1. Create your own driver
  1. Download the driver `.inf` file from: https://github.com/torvalds/linux/blob/master/Documentation/usb/linux.inf
  2. Add a new entry `CatalogFile` inside `[Version]` section, pointing to a `.cat` file with the same name.
  3. Run PowerShell as Administrator
  4. Type `.\DriverHelper.ps1 -Mode Sign -InfFile .\linux.inf`
2. Install the driver
  1. Open the device manager and locate the Raspberry Pi (usually under "Ports (COM &LPT)").
  2. Right click that device and select "Update driver"
  3. Choose "Browse my computer for driver software" and locate the directory of the `.inf` file.
  
**ATTENTION:** This will create a self-signed certificate and store it in your trusted root certificates store.
You can remove it by running `.\DriverHelper.ps1 -Mode UntrustCertificates -InfFile .\linux.inf`.

## Manage certificates
1. Either open PowerShell or the "Run Command" Windows app
2. Run `mmc.exe`
3. Navigate to __File > Add or Remove Snap-ins__
4. Select "Certificates" on the left and click "Add".
5. Now select "Computer Account", press "Next" and then "Finish"
6. Click "Ok".

The previously created certificate has been add to the following stores:
* Personal
* Trusted Root Certificate Authorities
* Trusted Publishers

By default, the common name `linux.local` was used. You can change that by providing `-CommonName "example.local"` to the script.