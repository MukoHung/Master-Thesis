# ConsoleBufferToHtml.ps1

## Synopsis
This is a Powershell script to dump console buffer as html to file.

## Syntax
ConsoleBufferToHtml.ps1 [-FilePath] <String> [[-Encoding] <String>] [[-Last] <Int32>] [-SkipLast]

## Description
This Powershell script will iterate over the current console buffer and output it as html preserving colors.
    
## Parameters

### -FilePath <String>
Specifies the path to the output file.

        Required?                    true
        Position?                    1
        Default value
        Accept pipeline input?       false
        Accept wildcard characters?  false

### -Encoding <String>
Specifies the type of character encoding used in the file. Valid values are "Unicode", "UTF7", "UTF8", "UTF32", "ASCII", "BigEndianUnicode"

        Required?                    false
        Position?                    2
        Default value                UTF8
        Accept pipeline input?       false
        Accept wildcard characters?  false

### -Last <Int32>
Specifies the rows to output from the end of the buffer

        Required?                    false
        Position?                    3
        Default value                0
        Accept pipeline input?       false
        Accept wildcard characters?  false

### -SkipLast [&lt;SwitchParameter&gt;]
Skips last buffer row in output

        Required?                    false
        Position?                    named
        Default value                False
        Accept pipeline input?       false
        Accept wildcard characters?  false


## Sample usage
`ConsoleBufferToHtml.ps1 -FilePath C:\temp\cakebuildlog.htm -Last 50`

![Cake screenshot](http://i.imgur.com/ngi9C71.png)

Will output [cakebuildlog.htm](https://gist.github.com/devlead/2e006ec4a7e134cf38c0/raw/2269b49a9d42843a4427ed2bcb39880ad325eb57/cakebuildlog.htm)