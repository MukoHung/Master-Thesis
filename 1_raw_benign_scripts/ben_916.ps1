# convertWebVTT
#
# This is a very basic and incomplete WebVTT to SRT converter. 
# It does not parse or understand the WebVTT elements NOTE, STYLE, REGION or any C-style comments in the WebVTT file. 
#
# Save this file to your desktop as ConvertWebVTT.ps1
# 
# Then create a shortcut for powershell to execute this file (change your username)
# C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe -noprofile -noexit -ExecutionPolicy ByPass -file C:\Users\brian\Desktop\ConvertWebVTT.ps1

# you can drag and drop a .vtt file onto the shortcut and it will convert the file.
#
# Brian A. Onn 

param ( [parameter(Mandatory=$true,ValueFromRemainingArguments=$true)]
        [string[]] $Paths )

ForEach ($Path in $Paths) {
    $Outfile = $Path -replace '(\.vtt|\.txt)','.srt'
    '' > $Outfile
    Get-Content $Path |
         ForEach-Object {
             $_ = $_ -replace '^WEBVTT.*$', ''
             if ($_ -match ':\d\d\.\d{1,3}.*-->') {  
               $_ = $_ -replace '(^|\s)(\d\d):(\d\d)\.(\d{1,3})', '${1}00:$2:$3,$4'
               $_ = $_ -replace ':(\d\d)\.(\d{1,3})', ':$1,$2'
             }
             $_ >> $Outfile
         }

"Converted $Path to $Outfile"
""
}