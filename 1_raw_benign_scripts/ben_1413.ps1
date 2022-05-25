function Expand-ZipArchive {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidateScript( { Test-Path $_ -PathType 'Leaf' })]
        [string]
        $Path,
        [ValidateScript( { Test-Path $_ -PathType 'Container' })]
        [string]
        $OutPath,
        [string[]]
        $Exclude,
        [string[]]
        $Include
    )

    begin {
        # load ZIP methods
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        # open ZIP archive for reading
        $zip = [System.IO.Compression.ZipFile]::OpenRead($Path)
    }

    process {

        # find all files in ZIP that match the filter (i.e. file extension)
        $zip.Entries |
        ForEach-Object {
            $FilePath = $_.FullName
            $FileName = $_.Name
            
            $extractFile = $false
            if ($Include.Count -eq 0 -and $Exclude.Count -eq 0) {
                Write-Host "$FilePath will be extracted"
                $extractFile = $true
            }
            else {
                if ($Include.Count -gt 0) {
                    $Include | ForEach-Object {
                        if ($FilePath -like $_ -or $FileName -like $_) {
                            $extractFile = $true
                        }   
                    }
                } else {
                    $extractFile =$true
                }
                if ($Exclude.Count -gt 0) {
                    $Exclude | ForEach-Object {
                        if ($FilePath -like $_ -or $FileName -like $_) {
                            $extractFile = ($extractFile -and $false)
                        } 
                    }
                }
            }
            # extract the selected items from the ZIP archive
            # and copy them to the out folder
            if ($extractFile -and -not ([String]::IsNullOrWhiteSpace($FileName))) {
                $OutFilePath = Join-Path -Path (Get-Item $OutPath).FullName -ChildPath $FilePath
                
                # Ensure parent directory exists
                $parentPath = Split-Path $OutFilePath -Parent
                if ( -not (Test-Path -PAth $parentPath -PathType Container)) {
                    New-Item -Path $parentPath -ItemType Directory
                }

                Write-Verbose "Extracting $FilePath ($FileName) to $OutFilePath"
                [System.IO.Compression.ZipFileExtensions]::ExtractToFile($_, $OutFilePath, $true)
            }
        }
    }

    end {
        # close ZIP file
        $zip.Dispose()
    }
}
