param(
    [Parameter(Mandatory=$True)]
    [string]$out,
    [Parameter()]
    [int]$margin = 16,
    [Parameter()]
    [int]$margintop = -1,
    [Parameter()]
    [int]$marginbottom = -1,
    [Parameter()]
    [int]$marginleft = -1,
    [Parameter()]
    [int]$marginright = -1,
    [Parameter(Position=0,ValueFromPipeline=$true,ValueFromPipelineByPropertyName=$true)]
    [Alias('FullName')]
    [String[]]$filePaths
)
 
begin {
    $ErrorActionPreference = "Stop"
    [void][Reflection.Assembly]::LoadWithPartialName('System.Drawing')
    
    $outPath = Resolve-Path $out
    $pmargintop = $margintop
    if($pmargintop -lt 0) {
        $pmargintop = $margin
    }
    $pmarginbottom = $marginbottom
    if($pmarginbottom -lt 0) {
        $pmarginbottom = $margin
    }
    $pmarginleft = $marginleft
    if($pmarginleft -lt 0) {
        $pmarginleft = $margin
    }
    $pmarginright = $marginright
    if($pmarginright -lt 0) {
        $pmarginright = $margin
    }
}

process {
    foreach($filePath in $filePaths) {
        $bitmap = New-Object Drawing.Bitmap ((Resolve-Path $filePath).ToString())
        if($null -eq $bitmap) {
            continue
        }
        try {
            $width = $bitmap.Width + $pmarginleft + $pmarginright
            $height = $bitmap.Height + $pmargintop + $pmarginbottom
            $resized = New-Object Drawing.Bitmap $width, $height, $bitmap.PixelFormat
            try {
                $g = [Drawing.Graphics]::FromImage($resized)
                try{
                    $g.FillRectangle([Drawing.Brushes]::White, (New-Object Drawing.Rectangle 0, 0, $width, $height))
                    $g.DrawImage($bitmap, (New-Object Drawing.Rectangle $pmarginleft, $pmargintop, $bitmap.Width, $bitmap.Height))
                }finally{
                    $g.Dispose()
                }
                $destpath = Join-Path $outPath ([IO.Path]::GetFileNameWithoutExtension($filePath) + "-margin.png")
                $resized.Save($destpath, [Drawing.Imaging.ImageFormat]::Png)
                Get-Item $destpath
            } finally {
                $resized.Dispose()
            }
        }finally{
            $bitmap.Dispose()
        }
    }
}