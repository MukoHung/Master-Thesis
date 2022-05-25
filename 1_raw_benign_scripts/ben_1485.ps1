<#
 .SYNOPSIS
Report on Disk Hogs
.DESCRIPTION
Returns a list of the largest directories in use on the local machine
.NOTES
Copyright Keith Garner, All rights reserved.
Really Updated for Windows 7 and Optimized for !!!SPEED!!!
.PARAMETER Path
Start of the search, usually c:\
.PARAMETER IncludeManifest
Include basic info about the memory, OS, and Disk in the manifest
.PARAMETER OutFile
CLIXML file used to store results
Location of a custom rules *.csv file, otherwise use the default table
.LINK
http://keithga.wordpress.com
#>

[cmdletbinding()]
param(
    $path = 'c:\',
    [switch] $IncludeManifest,
    $OutFile
)

###########################################################

$WatchList = @( 
    @{ Folder = 'c:\'; SizeMB = '0' }
    @{ Folder = 'c:\*'; SizeMB = '500' }
    @{ Folder = 'C:\$Recycle.Bin'; SizeMB = '100' }
    @{ Folder = 'c:\Program Files'; SizeMB = '0' }
    @{ Folder = 'C:\Program Files\*'; SizeMB = '1000' }
    @{ Folder = 'C:\Program Files (x86)'; SizeMB = '0' }
    @{ Folder = 'C:\Program Files (x86)\Adobe\*'; SizeMB = '1000' }
    @{ Folder = 'C:\Program Files (x86)\*'; SizeMB = '1000' }
    @{ Folder = 'C:\ProgramData\*'; SizeMB = '1000' }
    @{ Folder = 'C:\ProgramData'; SizeMB = '0' }
    @{ Folder = 'C:\Windows'; SizeMB = '0' }
    @{ Folder = 'C:\Windows\*'; SizeMB = '1000' }
    @{ Folder = 'c:\users'; SizeMB = '0' }
    @{ Folder = 'C:\Users\*'; SizeMB = '100' }
    @{ Folder = 'C:\Users\*\*'; SizeMB = '500' }
    @{ Folder = 'C:\Users\*\AppData\Local\Microsoft\*'; SizeMB = '1000' }
    @{ Folder = 'C:\Users\*\AppData\Local\*'; SizeMB = '400' }
)

###########################################################

Add-Type -TypeDefinition @"

    public class EnumFolder
    {


        public static System.Collections.Generic.Dictionary<string, long> ListDir(string Path, System.Collections.Generic.Dictionary<string, long> ControlList)
        {
            System.Collections.Generic.Dictionary<string, long> Results = new System.Collections.Generic.Dictionary<string, long>();

            System.IO.DirectoryInfo Root = new System.IO.DirectoryInfo(Path);
            ListDirRecursive(Root, Results, ControlList);
            return Results;
        }

        private static long ListDirRecursive
        (
            System.IO.DirectoryInfo Path,
            System.Collections.Generic.Dictionary<string, long> Results,
            System.Collections.Generic.Dictionary<string, long> ControlList
        )
        {
            try
            {
                long Total = 0;
                foreach (System.IO.DirectoryInfo Directory in Path.GetDirectories())
                    if ((Directory.Attributes & System.IO.FileAttributes.ReparsePoint) == 0)
                        Total += ListDirRecursive(Directory, Results, ControlList);

                foreach (System.IO.FileInfo file in Path.GetFiles())
                {
                    if ((file.Attributes & System.IO.FileAttributes.ReparsePoint) == 0)
                    {
                        if (ControlList.ContainsKey(file.FullName))
                        {
                            if ((ControlList[file.FullName] * 1024 * 1024) < file.Length)
                            {
                                Results.Add(file.FullName, file.Length);
                            }
                            else
                            {
                                Total += file.Length;
                            }
                        }
                        else
                        {
                            Total += file.Length;
                        }
                    }
                }

                if (ControlList.ContainsKey(Path.FullName))
                {
                    if ((ControlList[Path.FullName] * 1024 * 1024) < Total)
                    {
                        Results.Add(Path.FullName, Total);
                        Total = 0;
                    }
                }
                return Total;
            }
            catch
            {
                return 0;
            }
        }
    }
"@

###########################################################

$start = [datetime]::Now
$ControlList = new-object -TypeName 'System.Collections.Generic.Dictionary[String,int64]'

foreach ( $Item in $WatchList ) { 
    if ( $item.Folder.EndsWith('*') ) {
        get-childitem $Item.Folder.TrimEnd('*') -force -ErrorAction SilentlyContinue |
            ForEach-Object { 
                $_.FullName.Substring(0,1).ToLower() + $_.FullName.Substring(1)
            } | 
            Where-Object { -not $ControlList.ContainsKey( $_  ) } |
            foreach-object { $ControlList.Add($_,0 + $Item.SizeMB) }
    }
    else {
        get-item $Item.Folder -force -ErrorAction SilentlyContinue | 
            ForEach-Object { 
                $_.FullName.Substring(0,1).ToLower() + $_.FullName.Substring(1)
            } | 
            Where-Object { -not $ControlList.ContainsKey( $_  ) } |
            foreach-object { $ControlList.Add($_,0 + $Item.SizeMB) }
    }

} 

$ControlList.Keys | write-verbose

###################

$Results = [EnumFolder]::ListDir($Path.ToLower(), $ControlList )

$Results | write-output

([datetime]::now - $Start).TotalSeconds | Write-verbose

###################

if ( $OutFile ) {
    new-item -ItemType Directory -Path ( split-path $OutFile ) -ErrorAction SilentlyContinue | Out-Null
    if ( $IncludeManifest ) {
        @{ 
            OS   = GWMI Win32_OPeratingSystem | Select OSarchitecture,OSLanguage,InstallDate,Version
            Mem  = GWMI Win32_PhysicalMemory | Select Capacity
            Vol  = GWMI Win32_LogicalDisk -Filter "DeviceID='$($path.Substring(0,1))`:'" | Select Size,FreeSpace,VolumeName
            Data = $Results 
        } | Export-Clixml -Path $OutFile
    }
    else {
        $Results | Export-Clixml -Path $OutFile
    }
}
