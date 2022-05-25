gci $folder -fil '*.svn' -r -fo | ? {$_.psIsContainer} | ri -fo 
